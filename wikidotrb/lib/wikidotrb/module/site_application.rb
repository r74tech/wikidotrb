require 'nokogiri'
require_relative 'site'
require_relative 'user'
require_relative '../common/exceptions'
require_relative '../util/parser/odate'
require_relative '../util/parser/user'

module Wikidotrb
  module Module
    class SiteApplication
      attr_reader :site, :user, :text

      def initialize(site:, user:, text:)
        @site = site
        @user = user
        @text = text
      end

      def to_s
        "SiteApplication(user=#{user}, site=#{site}, text=#{text})"
      end

      def self.acquire_all(site:)
        # サイトへの未処理の申請を取得する
        # @param site [Site] サイト
        # @return [Array<SiteApplication>] 申請のリスト
        response = site.amc_request(
          bodies: [{ moduleName: 'managesite/ManageSiteMembersApplicationsModule' }]
        ).first

        body = response['body']

        if body.include?("WIKIDOT.page.listeners.loginClick(event)")
          raise Wikidotrb::Common::Exceptions::ForbiddenException.new(
            "You are not allowed to access this page"
          )
        end

        html = Nokogiri::HTML(response['body'])

        applications = []

        user_elements = html.css('h3 span.printuser')
        text_wrapper_elements = html.css('table')

        if user_elements.length != text_wrapper_elements.length
          raise Wikidotrb::Common::Exceptions::UnexpectedException.new(
            "Length of user_elements and text_wrapper_elements are different"
          )
        end

        user_elements.each_with_index do |user_element, i|
          text_wrapper_element = text_wrapper_elements[i]

          user = Wikidotrb::Util::Parser::UserParser.user(site.client, user_element)
          text = text_wrapper_element.css('td')[1].text.strip

          applications << SiteApplication.new(site: site, user: user, text: text)
        end

        applications
      end

      def _process(action)
        # 申請を処理する
        # @param action [String] 処理の種類 ('accept' または 'decline')
        unless %w[accept decline].include?(action)
          raise ArgumentError.new("Invalid action: #{action}")
        end

        begin
          site.amc_request(
            bodies: [{
              action: 'ManageSiteMembershipAction',
              event: 'acceptApplication',
              user_id: user.id,
              text: "your application has been #{action}ed",
              type: action,
              moduleName: 'Empty'
            }]
          )
        rescue Wikidotrb::Common::Exceptions::WikidotStatusCodeException => e
          if e.status_code == 'no_application'
            raise Wikidotrb::Common::Exceptions::NotFoundException.new(
              "Application not found: #{user}"
            ), e
          else
            raise e
          end
        end
      end

      # 申請を承認する
      def accept
        _process('accept')
      end

      # 申請を拒否する
      def decline
        _process('decline')
      end
    end
  end
end
