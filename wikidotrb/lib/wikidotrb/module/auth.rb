# frozen_string_literal: true

require "httpx"
require "uri"
require "json"
require_relative "../common/exceptions"

module Wikidotrb
  module Module
    class HTTPAuthentication
      # ユーザー名とパスワードでログインする
      # @param client [Client] クライアント
      # @param username [String] ユーザー名
      # @param password [String] パスワード
      # @raise [SessionCreateException] セッション作成に失敗した場合
      def self.login(client, username, password)
        url = "https://www.wikidot.com/default--flow/login__LoginPopupScreen"

        # ログインリクエストのデータを作成
        request_data = {
          "login" => username,
          "password" => password,
          "action" => "Login2Action",
          "event" => "login"
        }

        response = HTTPX.post(
          url,
          headers: client.amc_client.header.get_header,
          form: request_data,
          timeout: { operation: 20 }
        )

        # エラーレスポンスの処理
        if response.is_a?(HTTPX::ErrorResponse)
          raise Wikidotrb::Common::Exceptions::SessionCreateException,
                "Login attempt failed due to network error: #{response.error}"
        end

        # ステータスコードのチェック
        unless response.status == 200
          raise Wikidotrb::Common::Exceptions::SessionCreateException,
                "Login attempt failed due to HTTP status code: #{response.status}"
        end

        # レスポンスボディのチェック
        if response.body.to_s.include?("The login and password do not match")
          raise Wikidotrb::Common::Exceptions::SessionCreateException,
                "Login attempt failed due to invalid username or password"
        end

        # クッキーのチェックとパース
        set_cookie_header = response.headers["set-cookie"]

        # `set-cookie` が存在しない、または `nil` の場合にエラーを発生
        raise Wikidotrb::Common::Exceptions::SessionCreateException, "Login attempt failed due to invalid cookies" if set_cookie_header.nil? || set_cookie_header.empty?

        # セッションクッキーを取得
        session_cookie = set_cookie_header.match(/WIKIDOT_SESSION_ID=([^;]+)/)

        raise Wikidotrb::Common::Exceptions::SessionCreateException, "Login attempt failed due to invalid cookies" unless session_cookie

        # セッションクッキーの設定
        client.amc_client.header.set_cookie("WIKIDOT_SESSION_ID", session_cookie[1])
      end

      # ログアウトする
      # @param client [Client] クライアント
      def self.logout(client)
        begin
          client.amc_client.request(
            [{ "action" => "Login2Action", "event" => "logout", "moduleName" => "Empty" }]
          )
        rescue StandardError
          # 例外を無視してログアウト処理を続ける
        end

        client.amc_client.header.delete_cookie("WIKIDOT_SESSION_ID")
      end
    end
  end
end
