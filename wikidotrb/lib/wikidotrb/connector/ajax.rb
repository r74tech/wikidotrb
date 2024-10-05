require 'httpx'
require 'json'
require 'logger'
require 'concurrent'

require_relative '../common/exceptions'
require_relative '../common/logger'

module Wikidotrb
  module Connector
    # AjaxRequestHeaderの定義
    class AjaxRequestHeader
      # AjaxRequestHeaderオブジェクトの初期化
      # @param content_type [String] Content-Type
      # @param user_agent [String] User-Agent
      # @param referer [String] Referer
      # @param cookie [Hash] Cookie
      def initialize(content_type: nil, user_agent: nil, referer: nil, cookie: nil)
        @content_type = content_type || 'application/x-www-form-urlencoded; charset=UTF-8'
        @user_agent = user_agent || 'WikidotPy'
        @referer = referer || 'https://www.wikidot.com/'
        @cookie = { 'wikidot_token7' => 123456 }.merge(cookie || {})
      end

      # Cookieを設定
      # @param name [String] Cookie名
      # @param value [String] Cookie値
      def set_cookie(name, value)
        @cookie[name] = value
      end

      # Cookieを削除
      # @param name [String] Cookie名
      def delete_cookie(name)
        @cookie.delete(name)
      end

      # ヘッダを構築して返す
      # @return [Hash] ヘッダのハッシュ
      def get_header
        {
          'Content-Type' => @content_type,
          'User-Agent' => @user_agent,
          'Referer' => @referer,
          'Cookie' => @cookie.map { |name, value| "#{name}=#{value};" }.join
        }
      end
    end

    # AjaxModuleConnectorConfigの定義
    AjaxModuleConnectorConfig = Struct.new(
      :request_timeout, :attempt_limit, :retry_interval, :semaphore_limit,
      keyword_init: true
    ) do
      # デフォルト値を設定する
      def initialize(**args)
        super
        self.request_timeout ||= 20
        self.attempt_limit ||= 3
        self.retry_interval ||= 5
        self.semaphore_limit ||= 10
      end
    end

    # AjaxModuleConnectorClientの定義
    class AjaxModuleConnectorClient
      attr_reader :header
      # AjaxModuleConnectorClientオブジェクトの初期化
      # @param site_name [String] サイト名
      # @param config [AjaxModuleConnectorConfig] クライアントの設定
      def initialize(site_name: nil, config: nil)
        @site_name = site_name || 'www'
        @config = config || AjaxModuleConnectorConfig.new
        @ssl_supported = check_existence_and_ssl
        @header = AjaxRequestHeader.new
        @logger = Wikidotrb::Common::Logger
      end

      # サイトの存在とSSLの対応をチェック
      # @return [Boolean] SSL対応しているか
      # @raise [NotFoundException] サイトが見つからない場合
      def check_existence_and_ssl
        return true if @site_name == 'www' # wwwは常にSSL対応

        url = "http://#{@site_name}.wikidot.com"
        response = HTTPX.get(url)

        raise NotFoundException, "Site is not found: #{@site_name}.wikidot.com" if response.status == 404

        response.status == 301 && response.headers['location'].start_with?('https')
      end

      # ajax-module-connector.phpへのリクエストを行う
      # @param bodies [Array<Hash>] リクエストボディのリスト
      # @param return_exceptions [Boolean] 例外を返すかどうか
      # @param site_name [String] サイト名
      # @param site_ssl_supported [Boolean] サイトがSSL対応しているかどうか
      # @return [Array<Hash>] レスポンスボディのリスト
      # @raise [AMCHttpStatusCodeException, WikidotStatusCodeException, ResponseDataException]
      def request(bodies:, return_exceptions: false, site_name: nil, site_ssl_supported: nil)
        semaphore = Concurrent::Semaphore.new(@config.semaphore_limit)
        site_name ||= @site_name
        site_ssl_supported ||= @ssl_supported

        # 各リクエストを処理するための非同期タスク
        tasks = bodies.map do |body|
          Concurrent::Promises.future do
            retry_count = 0

            loop do
              # セマフォを使って同時実行数を制御
              semaphore.acquire

              begin
                url = "http#{'s' if site_ssl_supported}://#{site_name}.wikidot.com/ajax-module-connector.php"
                body['wikidot_token7'] = 123456
                @logger.debug("Ajax Request: #{url} -> #{body}")

                response = HTTPX.post(
                  url,
                  headers: @header.get_header,
                  form: body,
                  timeout: { operation: @config.request_timeout }
                )

                # ステータスが200以外の場合の処理
                if response.status != 200
                  retry_count += 1
                  if retry_count >= @config.attempt_limit
                    @logger.error("AMC is respond HTTP error code: #{response.status} -> #{body}")
                    raise AMCHttpStatusCodeException.new("AMC is respond HTTP error code: #{response.status}", response.status)
                  end

                  @logger.info("AMC is respond status: #{response.status} (retry: #{retry_count}) -> #{body}")
                  sleep @config.retry_interval
                  next
                end

                # レスポンスをJSONにパース
                response_body = JSON.parse(response.body.to_s)

                if response_body.nil? || response_body.empty?
                  @logger.error("AMC is respond empty data -> #{body}")
                  raise ResponseDataException, "AMC is respond empty data"
                end

                # ステータスのチェック
                if response_body['status']
                  if response_body['status'] == 'try_again'
                    retry_count += 1
                    if retry_count >= @config.attempt_limit
                      @logger.error("AMC is respond status: \"try_again\" -> #{body}")
                      raise WikidotStatusCodeException.new('AMC is respond status: "try_again"', 'try_again')
                    end

                    @logger.info("AMC is respond status: \"try_again\" (retry: #{retry_count})")
                    sleep @config.retry_interval
                    next
                  elsif response_body['status'] != 'ok'
                    @logger.error("AMC is respond error status: \"#{response_body['status']}\" -> #{body}")
                    raise WikidotStatusCodeException.new("AMC is respond error status: \"#{response_body['status']}\"", response_body['status'])
                  end
                end

                # レスポンスを返す
                break response_body
              rescue JSON::ParserError
                @logger.error("AMC is respond non-json data: \"#{response.body}\" -> #{body}")
                raise ResponseDataException.new("AMC is respond non-json data: \"#{response.body}\"")
              ensure
                semaphore.release
              end
            end
          end
        end

        # 全てのタスクの完了を待機
        results = Concurrent::Promises.zip(*tasks).value!

        # 結果を返す
        return_exceptions ? results : results.each { |r| raise r if r.is_a?(Exception) }
      end
    end
  end
end
