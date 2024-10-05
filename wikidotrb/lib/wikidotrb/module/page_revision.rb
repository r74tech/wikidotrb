require 'nokogiri'
require 'date'
require_relative 'page_source'

module Wikidotrb
  module Module
    class PageRevisionCollection < Array
      attr_accessor :page

      # 初期化メソッド
      # @param page [Page] ページオブジェクト
      # @param revisions [Array<PageRevision>] リビジョンのリスト
      def initialize(page: nil, revisions: [])
        super(revisions)
        @page = page || revisions.first.page
      end

      # イテレーションをオーバーライド
      def each(&block)
        super(&block)
      end

      # ソースを取得して設定する
      # @param page [Page] ページオブジェクト
      # @param revisions [Array<PageRevision>] リビジョンのリスト
      # @return [Array<PageRevision>] 更新されたリビジョンのリスト
      def self.acquire_sources(page:, revisions:)
        target_revisions = revisions.reject(&:source_acquired?)

        return revisions if target_revisions.empty?

        responses = page.site.amc_request(
          target_revisions.map do |revision|
            { "moduleName" => "history/PageSourceModule", "revision_id" => revision.id }
          end
        )

        responses.each_with_index do |response, index|
          body = JSON.parse(response.body.to_s)["body"]
          body_html = Nokogiri::HTML(body)
          target_revisions[index].source = PageSource.new(
            page: page,
            wiki_text: body_html.at_css("div.page-source").text.strip
          )
        end

        revisions
      end

      # HTMLを取得して設定する
      # @param page [Page] ページオブジェクト
      # @param revisions [Array<PageRevision>] リビジョンのリスト
      # @return [Array<PageRevision>] 更新されたリビジョンのリスト
      def self.acquire_htmls(page:, revisions:)
        target_revisions = revisions.reject(&:html_acquired?)

        return revisions if target_revisions.empty?

        responses = page.site.amc_request(
          target_revisions.map do |revision|
            { "moduleName" => "history/PageVersionModule", "revision_id" => revision.id }
          end
        )

        responses.each_with_index do |response, index|
          body = JSON.parse(response.body.to_s)["body"]
          # HTMLソースの抽出
          source = body.split(
            "onclick=\"document.getElementById('page-version-info').style.display='none'\">",
            2
          )[1].split("</a>\n\t</div>\n\n\n\n", 2)[1]
          target_revisions[index].html = source
        end

        revisions
      end

      # ソースをリビジョンに取得する
      def get_sources
        PageRevisionCollection.acquire_sources(page: @page, revisions: self)
      end

      # HTMLをリビジョンに取得する
      def get_htmls
        PageRevisionCollection.acquire_htmls(page: @page, revisions: self)
      end
    end

    class PageRevision
      attr_accessor :page, :id, :rev_no, :created_by, :created_at, :comment
      attr_reader :source, :html

      # 初期化メソッド
      # @param page [Page] ページオブジェクト
      # @param id [Integer] リビジョンID
      # @param rev_no [Integer] リビジョン番号
      # @param created_by [AbstractUser] 作成者
      # @param created_at [DateTime] 作成日時
      # @param comment [String] コメント
      # @param source [PageSource, nil] ページソース
      # @param html [String, nil] HTMLソース
      def initialize(page:, id:, rev_no:, created_by:, created_at:, comment:, source: nil, html: nil)
        @page = page
        @id = id
        @rev_no = rev_no
        @created_by = created_by
        @created_at = created_at
        @comment = comment
        @source = source
        @html = html
      end

      # ソースの取得状況を確認する
      # @return [Boolean] ソースが取得済みかどうか
      def source_acquired?
        !@source.nil?
      end

      # HTMLの取得状況を確認する
      # @return [Boolean] HTMLが取得済みかどうか
      def html_acquired?
        !@html.nil?
      end

      # ソースのゲッターメソッド
      # ソースが取得されていなければ取得する
      # @return [PageSource] ソースオブジェクト
      def source
        unless source_acquired?
          PageRevisionCollection.new(page: @page, revisions: [self]).get_sources
        end
        @source
      end

      # ソースのセッターメソッド
      def source=(value)
        @source = value
      end

      # HTMLのゲッターメソッド
      # HTMLが取得されていなければ取得する
      # @return [String] HTMLソース
      def html
        unless html_acquired?
          PageRevisionCollection.new(page: @page, revisions: [self]).get_htmls
        end
        @html
      end

      # HTMLのセッターメソッド
      def html=(value)
        @html = value
      end
    end
  end
end
