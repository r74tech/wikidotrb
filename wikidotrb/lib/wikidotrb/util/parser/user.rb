require 'nokogiri'
require_relative '../../module/user'

module Wikidotrb
  module Util
    module Parser
      class UserParser
        # printuser要素をパースし、ユーザーオブジェクトを返す
        # @param client [Client] クライアント
        # @param elem [Nokogiri::XML::Element] パース対象の要素（printuserクラスがついた要素）
        # @return [AbstractUser] パースされて得られたユーザーオブジェクト
        def self.parse(client, elem)
          return nil if elem.nil? || !elem.is_a?(Nokogiri::XML::Element)

          case
          when elem['class']&.include?('deleted')
            # "deleted"クラスがある場合はDeletedUser
            parse_deleted_user(client, elem)

          when elem['class']&.include?('anonymous')
            # "anonymous"クラスがある場合はAnonymousUser
            parse_anonymous_user(client, elem)

          when gravatar_avatar?(elem)
            # "gravatar.com"を含むsrc属性のimg要素はGuestUser
            # ref: https://www.wikidot.com/more:explore-features#toc13
            parse_guest_user(client, elem)

          when elem.text.strip == 'Wikidot'
            # テキストが"Wikidot"の場合はWikidotUser
            parse_wikidot_user(client)

          else
            # それ以外はUser
            parse_regular_user(client, elem)
          end
        end

        private

        def self.parse_deleted_user(client, elem)
          id = elem['data-id'].to_i
          Wikidotrb::Module::DeletedUser.new(client: client, id: id)
        end

        def self.parse_anonymous_user(client, elem)
          masked_ip = elem.at_css('span.ip').text.gsub(/[()]/, '').strip
          ip = masked_ip  # デフォルトはマスクされたIP

          # 完全なIPが取得できる場合はそちらを使用
          if (onclick_attr = elem.at_css('a')['onclick'])
            match_data = onclick_attr.match(/WIKIDOT.page.listeners.anonymousUserInfo\('(.+?)'\)/)
            ip = match_data[1] if match_data
          end

          Wikidotrb::Module::AnonymousUser.new(client: client, ip: ip, ip_masked: masked_ip)
        end

        def self.parse_guest_user(client, elem)
          guest_name = elem.text.strip.split(' ').first
          avatar_url = elem.at_css('img')['src']
          Wikidotrb::Module::GuestUser.new(client: client, name: guest_name, avatar_url: avatar_url)
        end

        def self.parse_wikidot_user(client)
          Wikidotrb::Module::WikidotUser.new(client: client)
        end

        def self.parse_regular_user(client, elem)
          user_anchor = elem.css('a').last
          user_name = user_anchor.text.strip
          user_unix = user_anchor['href'].to_s.gsub('http://www.wikidot.com/user:info/', '')
          user_id = user_anchor['onclick'].to_s.match(/WIKIDOT.page.listeners.userInfo\((\d+)\)/)[1].to_i
          
          Wikidotrb::Module::User.new(
            client: client,
            id: user_id,
            name: user_name,
            unix_name: user_unix,
            avatar_url: "http://www.wikidot.com/avatar.php?userid=#{user_id}"
          )
        end

        def self.gravatar_avatar?(elem)
          avatar_elem = elem.at_css('img')
          avatar_elem && avatar_elem['src'].include?('gravatar.com')
        end
      end
    end
  end
end
