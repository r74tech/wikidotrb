# frozen_string_literal: true

require "httpx"
require_relative "forum"
require_relative "page"
require_relative "site_application"
require_relative "../common/exceptions"
require_relative "../common/decorators"

module Wikidotrb
  module Module
    class SitePagesMethods
      def initialize(site)
        @site = site
      end

      # ページを検索する
      # @param kwargs [Hash] 検索クエリのパラメータ
      # @return [PageCollection] ページのコレクション
      def search(**kwargs)
        query = SearchPagesQuery.new(**kwargs)
        PageCollection.search_pages(@site, query)
      end
    end

    class SitePageMethods
      def initialize(site)
        @site = site
      end

      # フルネームからページを取得する
      # @param fullname [String] ページのフルネーム
      # @param raise_when_not_found [Boolean] ページが見つからない場合に例外を発生させるかどうか
      # @return [Page, nil] ページオブジェクト、もしくはnil
      def get(fullname, raise_when_not_found: true)
        res = PageCollection.search_pages(@site, Wikidotrb::Module::SearchPagesQuery.new(fullname: fullname))

        if res.empty?
          raise Wikidotrb::Common::Exceptions::NotFoundException, "Page is not found: #{fullname}" if raise_when_not_found

          return nil
        end

        res.first
      end

      # ページを作成する
      # @param fullname [String] ページのフルネーム
      # @param title [String] ページのタイトル
      # @param source [String] ページのソース
      # @param comment [String] コメント
      # @param force_edit [Boolean] ページが存在する場合に上書きするかどうか
      # @return [Page] 作成されたページオブジェクト
      def create(fullname:, title: "", source: "", comment: "", force_edit: false)
        Page.create_or_edit(
          site: @site,
          fullname: fullname,
          title: title,
          source: source,
          comment: comment,
          force_edit: force_edit,
          raise_on_exists: true
        )
      end
    end

    class Site
      attr_reader :client, :id, :title, :unix_name, :domain, :ssl_supported, :pages, :page

      extend Wikidotrb::Common::Decorators

      def initialize(client:, id:, title:, unix_name:, domain:, ssl_supported:)
        @client = client
        @id = id
        @title = title
        @unix_name = unix_name
        @domain = domain
        @ssl_supported = ssl_supported

        @pages = SitePagesMethods.new(self)
        @page = SitePageMethods.new(self)
        @forum = Forum.new(site: self)
      end

      def to_s
        "Site(id=#{id}, title=#{title}, unix_name=#{unix_name})"
      end

      # UNIX名からサイトオブジェクトを取得する
      # @param client [Client] クライアント
      # @param unix_name [String] サイトのUNIX名
      # @return [Site] サイトオブジェクト
      def self.from_unix_name(client:, unix_name:)
        url = "http://#{unix_name}.wikidot.com"
        timeout = { connect: client.amc_client.config.request_timeout }
        response = HTTPX.with(timeout: timeout).get(url)

        # リダイレクトの対応
        while response.status >= 300 && response.status < 400
          url = response.headers["location"]
          response = HTTPX.with(timeout: timeout).get(url)
        end

        # サイトが存在しない場合
        raise Wikidotrb::Common::Exceptions::NotFoundException, "Site is not found: #{unix_name}.wikidot.com" if response.status == 404

        # サイトが存在する場合
        source = response.body.to_s

        # id : WIKIREQUEST.info.siteId = xxxx;
        id_match = source.match(/WIKIREQUEST\.info\.siteId = (\d+);/)
        raise Wikidotrb::Common::Exceptions::UnexpectedException, "Cannot find site id: #{unix_name}.wikidot.com" if id_match.nil?

        site_id = id_match[1].to_i

        # title : titleタグ
        title_match = source.match(%r{<title>(.*?)</title>})
        raise Wikidotrb::Common::Exceptions::UnexpectedException, "Cannot find site title: #{unix_name}.wikidot.com" if title_match.nil?

        title = title_match[1]

        # unix_name : WIKIREQUEST.info.siteUnixName = "xxxx";
        unix_name_match = source.match(/WIKIREQUEST\.info\.siteUnixName = "(.*?)";/)
        if unix_name_match.nil?
          raise Wikidotrb::Common::Exceptions::UnexpectedException,
                "Cannot find site unix_name: #{unix_name}.wikidot.com"
        end

        unix_name = unix_name_match[1]

        # domain : WIKIREQUEST.info.domain = "xxxx";
        domain_match = source.match(/WIKIREQUEST\.info\.domain = "(.*?)";/)
        raise Wikidotrb::Common::Exceptions::UnexpectedException, "Cannot find site domain: #{unix_name}.wikidot.com" if domain_match.nil?

        domain = domain_match[1]

        # SSL対応チェック
        ssl_supported = response.uri.to_s.start_with?("https")

        new(
          client: client,
          id: site_id,
          title: title,
          unix_name: unix_name,
          domain: domain,
          ssl_supported: ssl_supported
        )
      end

      # このサイトに対してAMCリクエストを実行する
      # @param bodies [Array<Hash>] リクエストボディのリスト
      # @param return_exceptions [Boolean] 例外を返すかどうか
      def amc_request(bodies:, return_exceptions: false)
        client.amc_client.request(
          bodies: bodies,
          return_exceptions: return_exceptions,
          site_name: unix_name,
          site_ssl_supported: ssl_supported
        )
      end

      # サイトへの未処理の参加申請を取得する
      # @return [Array<SiteApplication>] 未処理の申請リスト
      def get_applications
        SiteApplication.acquire_all(site: self)
      end

      # ユーザーをサイトに招待する
      # @param user [User] 招待するユーザー
      # @param text [String] 招待文
      def invite_user(user:, text:)
        amc_request(
          bodies: [{
            action: "ManageSiteMembershipAction",
            event: "inviteMember",
            user_id: user.id,
            text: text,
            moduleName: "Empty"
          }]
        )
      rescue Wikidotrb::Common::Exceptions::WikidotStatusCodeException => e
        case e.status_code
        when "already_invited"
          raise Wikidotrb::Common::Exceptions::TargetErrorException.new(
            "User is already invited to #{unix_name}: #{user.name}"
          ), e
        when "already_member"
          raise Wikidotrb::Common::Exceptions::TargetErrorException.new(
            "User is already a member of #{unix_name}: #{user.name}"
          ), e
        else
          raise e
        end
      end

      # サイトのURLを取得する
      # @return [String] サイトのURL
      def get_url
        "http#{ssl_supported ? "s" : ""}://#{domain}"
      end

      # `invite_user`にデコレータを適用
      login_required :invite_user
      login_required :get_applications
    end
  end
end
