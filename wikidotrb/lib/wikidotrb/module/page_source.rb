module Wikidotrb
  module Module
    class PageSource
      attr_accessor :page, :wiki_text

      # 初期化メソッド
      # @param page [Page] ページオブジェクト
      # @param wiki_text [String] ページのWikiテキスト
      def initialize(page:, wiki_text:)
        @page = page
        @wiki_text = wiki_text
      end
    end
  end
end
