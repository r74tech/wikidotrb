# frozen_string_literal: true

require "httpx"
require "concurrent"

module Wikidotrb
  module Util
    class RequestUtil
      # GETリクエストを送信する
      # @param client [Client] クライアント
      # @param method [String] リクエストメソッド
      # @param urls [Array<String>] URLのリスト
      # @param return_exceptions [Boolean] 例外を返すかどうか
      # @return [Array<HTTPX::Response, Exception>] レスポンスのリスト
      def self.request(client:, method:, urls:, return_exceptions: false)
        config = client.amc_client.config
        semaphore = Concurrent::Semaphore.new(config.semaphore_limit)

        # リクエスト処理を行う非同期タスク
        tasks = urls.map do |url|
          Concurrent::Promises.future do
            semaphore.acquire

            begin
              case method.upcase
              when "GET"
                response = HTTPX.get(url)
              when "POST"
                response = HTTPX.post(url)
              else
                raise ArgumentError, "Invalid method"
              end

              response
            rescue StandardError => e
              e
            ensure
              semaphore.release
            end
          end
        end

        # 全てのタスクの完了を待機
        results = Concurrent::Promises.zip(*tasks).value!

        # 例外を返すかどうかのオプションに応じて結果を返す
        return_exceptions ? results : results.each { |r| raise r if r.is_a?(Exception) }
      end
    end
  end
end
