require 'nokogiri'
require_relative '../common/exceptions'
require_relative '../util/requestutil'
require_relative '../util/stringutil'

module Wikidotrb
  module Module
    # ユーザーのコレクションを表すクラス
    class UserCollection < Array
      # ユーザー名のリストからユーザーオブジェクトのリストを取得する
      # @param client [Client] クライアント
      # @param names [Array<String>] ユーザー名のリスト
      # @param raise_when_not_found [Boolean] ユーザーが見つからない場合に例外を送出するか
      # @return [UserCollection] ユーザーオブジェクトのリスト
      def self.from_names(client, names, raise_when_not_found = false)
        urls = names.map { |name| "https://www.wikidot.com/user:info/#{Wikidotrb::Util::StringUtil.to_unix(name)}" }

        responses = Wikidotrb::Util::RequestUtil.request(client: client, method: 'GET', urls: urls)

        users = []

        responses.each do |response|
          if response.is_a?(Exception)
            raise response
          end

          html = Nokogiri::HTML(response.body.to_s)

          # 存在チェック
          if html.at_css('div.error-block')
            raise NotFoundException, "User not found: #{response.uri}" if raise_when_not_found

            next
          end

          # idの取得
          user_id = html.at_css('a.btn.btn-default.btn-xs')['href'].split('/').last.to_i

          # nameの取得
          name = html.at_css('h1.profile-title').text.strip

          # avatar_urlの取得
          avatar_url = "https://www.wikidot.com/avatar.php?userid=#{user_id}"

          users << User.new(
            client: client,
            id: user_id,
            name: name,
            unix_name: Wikidotrb::Util::StringUtil.to_unix(name),
            avatar_url: avatar_url
          )
        end

        new(users)
      end
    end

    # ユーザーオブジェクトの抽象クラス
    class AbstractUser
      attr_accessor :client, :id, :name, :unix_name, :avatar_url, :ip, :ip_masked

      def initialize(client:, id: nil, name: nil, unix_name: nil, avatar_url: nil, ip: nil, ip_masked: nil)
        @client = client
        @id = id
        @name = name
        @unix_name = unix_name
        @avatar_url = avatar_url
        @ip = ip
        @ip_masked = ip_masked
      end
    end

    # 一般のユーザーオブジェクト
    class User < AbstractUser
      attr_accessor :client, :id, :name, :unix_name, :avatar_url, :ip

      def initialize(client:, id: nil, name: nil, unix_name: nil, avatar_url: nil)
        super(client: client, id: id, name: name, unix_name: unix_name, avatar_url: avatar_url)
      end

      # ユーザー名からユーザーオブジェクトを取得する
      # @param client [Client] クライアント
      # @param name [String] ユーザー名
      # @param raise_when_not_found [Boolean] ユーザーが見つからない場合に例外を送出するか
      # @return [User] ユーザーオブジェクト
      def self.from_name(client, name, raise_when_not_found = false)
        UserCollection.from_names(client, [name], raise_when_not_found).first
      end
    end

    # 削除されたユーザーオブジェクト
    class DeletedUser < AbstractUser
      def initialize(client:, id: nil)
        super(client: client, id: id, name: 'account deleted', unix_name: 'account_deleted', avatar_url: nil)
      end
    end

    # 匿名ユーザーオブジェクト
    class AnonymousUser < AbstractUser
      def initialize(client:, ip: nil, ip_masked: nil)
        super(client: client, id: nil, name: 'Anonymous', unix_name: 'anonymous', avatar_url: nil, ip: ip, ip_masked: ip_masked)
      end
    end

    # ゲストユーザーオブジェクト
    class GuestUser < AbstractUser
      def initialize(client:, name:, avatar_url:)
        super(client: client, id: nil, name: name, unix_name: nil, avatar_url: avatar_url)
      end
    end

    # Wikidotシステムユーザーオブジェクト
    class WikidotUser < AbstractUser
      def initialize(client:)
        super(client: client, id: nil, name: 'Wikidot', unix_name: 'wikidot', avatar_url: nil)
      end
    end
  end
end
