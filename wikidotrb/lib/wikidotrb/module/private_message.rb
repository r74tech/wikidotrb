# frozen_string_literal: true

require "httpx"
require "nokogiri"
require "date"
require_relative "client"
require_relative "user"
require_relative "../common/exceptions"
require_relative "../common/decorators"
require_relative "../util/parser/odate"
require_relative "../util/parser/user"

module Wikidotrb
  module Module
    class PrivateMessageCollection < Array
      extend Wikidotrb::Common::Decorators

      def to_s
        "#{self.class.name}(#{size} messages)"
      end

      def self.from_ids(client:, message_ids:)
        bodies = message_ids.map do |message_id|
          { item: message_id, moduleName: "dashboard/messages/DMViewMessageModule" }
        end

        responses = client.amc_client.request(bodies: bodies, return_exceptions: true)

        messages = []

        responses.each_with_index do |response, index|
          if response.is_a?(Wikidotrb::Common::Exceptions::WikidotStatusCodeException) && response.status_code == "no_message"
            raise Wikidotrb::Common::Exceptions::ForbiddenException.new(
              "Failed to get message: #{message_ids[index]}"
            ), response
          end

          raise response if response.is_a?(Exception)

          next unless response && response["body"]

          html = Nokogiri::HTML(response["body"])
          sender, recipient = html.css("div.pmessage div.header span.printuser")
          messages << PrivateMessage.new(
            client: client,
            id: message_ids[index],
            sender: Wikidotrb::Util::Parser::UserParser.parse(client, sender),
            recipient: Wikidotrb::Util::Parser::UserParser.parse(client, recipient),
            subject: html.css("div.pmessage div.header span.subject").text.strip,
            body: html.css("div.pmessage div.body").text.strip,
            created_at: Wikidotrb::Util::Parser::ODateParser.parse(html.css("div.header span.odate"))
          )
        end

        new(messages)
      end

      def self._acquire(client:, module_name:)
        response = client.amc_client.request(bodies: [{ moduleName: module_name }])[0]

        html = Nokogiri::HTML(response["body"]) if response && response["body"]
        pager = html.css("div.pager span.target")
        max_page = pager.length > 2 ? pager[-2].text.to_i : 1

        responses = if max_page > 1
                      bodies = (1..max_page).map { |page| { page: page, moduleName: module_name } }
                      client.amc_client.request(bodies: bodies, return_exceptions: false)
                    else
                      [response]
                    end

        message_ids = []
        responses.each do |res|
          html = Nokogiri::HTML(res["body"]) if res && res["body"]
          message_ids += html.css("tr.message").map { |tr| tr["data-href"].split("/").last.to_i }
        end

        from_ids(client: client, message_ids: message_ids)
      end

      # メソッドが定義された後にデコレータを適用
      login_required :from_ids, :_acquire
    end

    class PrivateMessageInbox < PrivateMessageCollection
      def self.from_ids(client:, message_ids:)
        new(super)
      end

      def self.acquire(client:)
        new(_acquire(client: client, module_name: "dashboard/messages/DMInboxModule"))
      end
    end

    class PrivateMessageSentBox < PrivateMessageCollection
      def self.from_ids(client:, message_ids:)
        new(super)
      end

      def self.acquire(client:)
        new(_acquire(client: client, module_name: "dashboard/messages/DMSentModule"))
      end
    end

    class PrivateMessage
      attr_reader :client, :id, :sender, :recipient, :subject, :body, :created_at

      def initialize(client:, id:, sender:, recipient:, subject:, body:, created_at:)
        @client = client
        @id = id
        @sender = sender
        @recipient = recipient
        @subject = subject
        @body = body
        @created_at = created_at
      end

      def to_s
        "PrivateMessage(id=#{id}, sender=#{sender}, recipient=#{recipient}, subject=#{subject})"
      end

      def self.from_id(client:, message_id:)
        PrivateMessageCollection.from_ids(client: client, message_ids: [message_id]).first
      end

      def self.send_message(client:, recipient:, subject:, body:)
        client.amc_client.request(
          bodies: [{
            source: body,
            subject: subject,
            to_user_id: recipient.id,
            action: "DashboardMessageAction",
            event: "send",
            moduleName: "Empty"
          }]
        )
      end

      # メソッド定義後にデコレータを適用
      extend Wikidotrb::Common::Decorators
      login_required :send_message
    end
  end
end
