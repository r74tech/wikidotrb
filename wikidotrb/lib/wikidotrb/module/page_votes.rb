# frozen_string_literal: true

module Wikidotrb
  module Module
    class PageVoteCollection < Array
      attr_accessor :page

      # 初期化メソッド
      # @param page [Page] ページオブジェクト
      # @param votes [Array<PageVote>] 投票オブジェクトのリスト
      def initialize(page:, votes: [])
        super(votes)
        @page = page
      end
    end

    class PageVote
      attr_accessor :page, :user, :value

      # 初期化メソッド
      # @param page [Page] ページオブジェクト
      # @param user [AbstractUser] ユーザーオブジェクト
      # @param value [Integer] 投票の値
      def initialize(page:, user:, value:)
        @page = page
        @user = user
        @value = value
      end
    end
  end
end
