require 'nokogiri'
require_relative '../../module/user'

module Wikidotrb
  module Module
    class UserParser
      # printuser要素をパースし、ユーザーオブジェクトを返す
      # @param client [Client] クライアント
      # @param elem [Nokogiri::XML::Element] パース対象の要素（printuserクラスがついた要素）
      # @return [AbstractUser] パースされて得られたユーザーオブジェクト
      def self.user_parse(client, elem)
        # "deleted"クラスが含まれる場合はDeletedUserを返す
        if elem['class']&.include?('deleted')
          return Wikidotrb::Module::User::DeletedUser.new(client: client, id: elem['data-id'].to_i)

        # "anonymous"クラスが含まれる場合はAnonymousUserを返す
        elsif elem['class']&.include?('anonymous')
          ip = elem.at_css('span.ip').text.gsub(/[()]/, '').strip
          return Wikidotrb::Module::User::AnonymousUser.new(client: client, ip: ip)

        # "Wikidot"テキストの場合はWikidotUserを返す
        elsif elem.text.strip == 'Wikidot'
          return Wikidotrb::Module::User::WikidotUser.new(client: client)

        # 通常ユーザーの場合
        else
          _user = elem.css('a').last
          user_name = _user.text.strip
          user_unix = _user['href'].to_s.gsub('http://www.wikidot.com/user:info/', '')
          user_id = _user['onclick'].to_s.gsub('WIKIDOT.page.listeners.userInfo(', '').gsub('); return false;', '').to_i

          return Wikidotrb::Module::User::User.new(
            client: client,
            id: user_id,
            name: user_name,
            unix_name: user_unix,
            avatar_url: "http://www.wikidot.com/avatar.php?userid=#{user_id}"
          )
        end
      end
    end
  end
end
