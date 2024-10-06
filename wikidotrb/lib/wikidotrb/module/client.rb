require_relative '../common/logger'
require_relative '../common/exceptions'
require_relative '../connector/ajax'
require_relative 'auth'
require_relative 'private_message'
require_relative 'site'
require_relative 'user'

module Wikidotrb
  module Module
    class ClientUserMethods
      attr_reader :client

      def initialize(client)
        @client = client
      end

      # ユーザー名からユーザーオブジェクトを取得する
      # @param name [String] ユーザー名
      # @param raise_when_not_found [Boolean] ユーザーが見つからない場合に例外を送出するか
      # @return [User] ユーザーオブジェクト
      def get(name, raise_when_not_found: false)
        Wikidotrb::Module::User.from_name(@client, name, raise_when_not_found)
      end

      # ユーザー名からユーザーオブジェクトを取得する
      # @param names [Array<String>] ユーザー名のリスト
      # @param raise_when_not_found [Boolean] ユーザーが見つからない場合に例外を送出するか
      # @return [Array<User>] ユーザーオブジェクトのリスト
      def get_bulk(names, raise_when_not_found: false)
        Wikidotrb::Module::UserCollection.from_names(@client, names, raise_when_not_found)
      end
    end

    class ClientPrivateMessageMethods
      attr_reader :client

      def initialize(client)
        @client = client
      end

      # メッセージを送信する
      # @param recipient [User] 受信者
      # @param subject [String] 件名
      # @param body [String] 本文
      def send_message(recipient, subject, body)
        Wikidotrb::Module::PrivateMessage.send_message(
          client: @client, recipient: recipient, subject: subject, body: body
        )
      end

      # 受信箱を取得する
      # @return [PrivateMessageInbox] 受信箱
      def get_inbox
        Wikidotrb::Module::PrivateMessageInbox.acquire(client: @client)
      end

      # 送信箱を取得する
      # @return [PrivateMessageSentBox] 送信箱
      def get_sentbox
        Wikidotrb::Module::PrivateMessageSentBox.acquire(client: @client)
      end

      # メッセージを取得する
      # @param message_ids [Array<Integer>] メッセージIDのリスト
      # @return [PrivateMessageCollection] メッセージのリスト
      def get_messages(message_ids)
        Wikidotrb::Module::PrivateMessageCollection.from_ids(client: @client, message_ids: message_ids)
      end

      # メッセージを取得する
      # @param message_id [Integer] メッセージID
      # @return [PrivateMessage] メッセージ
      def get_message(message_id)
        Wikidotrb::Module::PrivateMessage.from_id(client: @client, message_id: message_id)
      end
    end

    class ClientSiteMethods
      attr_reader :client

      def initialize(client)
        @client = client
      end

      # UNIX名からサイトオブジェクトを取得する
      # @param unix_name [String] サイトのUNIX名
      # @return [Site] サイトオブジェクト
      def get(unix_name)
        Wikidotrb::Module::Site.from_unix_name(client: client, unix_name: unix_name)
      end
    end

    class Client
      attr_accessor :amc_client, :is_logged_in, :username
      attr_reader :user, :private_message, :site

      # 基幹クライアント
      def initialize(username: nil, password: nil, amc_config: nil, logging_level: 'WARN')
        # 最初にロギングレベルを決定する
        Wikidotrb::Common::Logger.level = logging_level

        # AMCClientを初期化
        @amc_client = Wikidotrb::Connector::AjaxModuleConnectorClient.new(site_name: "www", config: amc_config)

        # セッション関連変数の初期化
        @is_logged_in = false
        @username = nil

        # usernameとpasswordが指定されていればログインする
        if username && password
          Wikidotrb::Module::HTTPAuthentication.login(self, username, password)
          @is_logged_in = true
          @username = username
        end

        # メソッドの定義
        @user = ClientUserMethods.new(self)
        @private_message = ClientPrivateMessageMethods.new(self)
        @site = ClientSiteMethods.new(self)
      end

      # デストラクタ
      def finalize
        if @is_logged_in
          Wikidotrb::Module::HTTPAuthentication.logout(self)
          @is_logged_in = false
          @username = nil
        end
      end

      def to_s
        "Client(username=#{@username}, is_logged_in=#{@is_logged_in})"
      end

      # ログインチェック
      def login_check
        unless @is_logged_in
          raise Wikidotrb::Common::Exceptions::LoginRequiredException.new("Login is required to execute this function")
        end
        nil
      end
    end
  end
end
