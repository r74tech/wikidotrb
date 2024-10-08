# frozen_string_literal: true

require "nokogiri"
require_relative "../common/exceptions"
require_relative "forum_thread"
require_relative "page_revision"
require_relative "page_source"
require_relative "page_votes"
require_relative "../util/requestutil"
require_relative "../util/parser/user"
require_relative "../util/parser/odate"

module Wikidotrb
  module Module
    DEFAULT_MODULE_BODY = [
      "fullname",  # ページのフルネーム(str)
      "category",  # カテゴリ(str)
      "name", # ページ名(str)
      "title", # タイトル(str)
      "created_at", # 作成日時(odate element)
      "created_by_linked", # 作成者(user element)
      "updated_at", # 更新日時(odate element)
      "updated_by_linked", # 更新者(user element)
      "commented_at", # コメント日時(odate element)
      "commented_by_linked", # コメントしたユーザ(user element)
      "parent_fullname", # 親ページのフルネーム(str)
      "comments", # コメント数(int)
      "size", # サイズ(int)
      "children", # 子ページ数(int)
      "rating_votes", # 投票数(int)
      "rating", # レーティング(int or float)
      "rating_percent", # 5つ星レーティング(%)
      "revisions", # リビジョン数(int)
      "tags", # タグのリスト(list of str)
      "_tags" # 隠しタグのリスト(list of str)
    ].freeze

    class SearchPagesQuery
      attr_accessor :pagetype, :category, :tags, :parent, :link_to, :created_at, :updated_at,
                    :created_by, :rating, :votes, :name, :fullname, :range, :order,
                    :offset, :limit, :perPage, :separate, :wrapper

      def initialize(pagetype: "*", category: "*", tags: nil, parent: nil, link_to: nil, created_at: nil, updated_at: nil,
                     created_by: nil, rating: nil, votes: nil, name: nil, fullname: nil, range: nil, order: "created_at desc",
                     offset: 0, limit: nil, perPage: 250, separate: "no", wrapper: "no")
        @pagetype = pagetype
        @category = category
        @tags = tags
        @parent = parent
        @link_to = link_to
        @created_at = created_at
        @updated_at = updated_at
        @created_by = created_by
        @rating = rating
        @votes = votes
        @name = name
        @fullname = fullname
        @range = range
        @order = order
        @offset = offset
        @limit = limit
        @perPage = perPage
        @separate = separate
        @wrapper = wrapper
      end

      def to_h
        res = instance_variables.to_h { |var| [var.to_s.delete("@"), instance_variable_get(var)] }
        res.compact!
        res["tags"] = res["tags"].join(" ") if res["tags"].is_a?(Array)
        res
      end
    end

    class PageCollection < Array
      attr_accessor :site

      def initialize(site: nil, pages: [])
        super(pages)
        @site = site || pages.first&.site
      end

      def self.parse(site, html_body)
        pages = []

        html_body.css("div.page").each do |page_element|
          page_params = {}

          # レーティング方式を判定
          is_5star_rating = !page_element.css("span.rating span.page-rate-list-pages-start").empty?

          # 各値を取得
          page_element.css("span.set").each do |set_element|
            key = set_element.css("span.name").text.strip
            value_element = set_element.css("span.value")

            value = if value_element.empty?
                      nil
                    elsif %w[created_at updated_at commented_at].include?(key)
                      odate_element = value_element.css("span.odate")
                      odate_element.empty? ? nil : Wikidotrb::Util::Parser::ODateParser.parse(odate_element)
                    elsif %w[created_by_linked updated_by_linked commented_by_linked].include?(key)
                      printuser_element = value_element.css("span.printuser")
                      if printuser_element.empty?
                        nil
                      else
                        Wikidotrb::Util::Parser::UserParser.parse(site.client,
                                                                  printuser_element)
                      end
                    elsif %w[tags _tags].include?(key)
                      value_element.text.split
                    elsif %w[rating_votes comments size revisions].include?(key)
                      value_element.text.strip.to_i
                    elsif key == "rating"
                      is_5star_rating ? value_element.text.strip.to_f : value_element.text.strip.to_i
                    elsif key == "rating_percent"
                      is_5star_rating ? value_element.text.strip.to_f / 100 : nil
                    else
                      value_element.text.strip
                    end

            # keyを変換
            key = key.gsub("_linked", "") if key.include?("_linked")
            key = "#{key}_count" if %w[comments children revisions].include?(key)
            key = "votes_count" if key == "rating_votes"

            page_params[key.to_sym] = value
          end

          # タグのリストを統合
          page_params[:tags] ||= []
          page_params[:tags] += page_params.delete(:_tags) || []

          # ページオブジェクトを作成
          pages << Page.new(site: site, **page_params)
        end

        new(site: site, pages: pages)
      end

      def self.search_pages(site, query = SearchPagesQuery.new)
        # クエリの初期化
        query_dict = query.to_h
        query_dict["moduleName"] = "list/ListPagesModule"
        query_dict["module_body"] = %(
          [[div class="page"]]
          #{DEFAULT_MODULE_BODY.map do |key|
            %(
            [[span class="set #{key}"]]
              [[span class="name"]]#{key}[[/span]]
              [[span class="value"]]%%#{key}%%[[/span]]
            [[/span]]
          )
          end.join("\n")}
          [[/div]]
        )

        begin
          # 初回リクエスト
          response_data = site.amc_request(bodies: [query_dict])[0]
        rescue Wikidotrb::Common::Exceptions::WikidotStatusCodeException => e
          raise Wikidotrb::Common::Exceptions::ForbiddenException, "Failed to get pages, target site may be private" if e.status_code == "not_ok"

          raise e
        end

        body = response_data["body"]
        first_page_html_body = Nokogiri::HTML(body)

        total = 1
        html_bodies = [first_page_html_body]

        # pagerの存在を確認
        pager_element = first_page_html_body.css("div.pager")
        unless pager_element.empty?
          # 最大ページ数を取得
          total = pager_element.css("span.target")[-2].css("a").text.to_i
        end

        # 複数ページが存在する場合はリクエストを繰り返す
        if total > 1
          request_bodies = []
          (1...total).each do |i|
            _query_dict = query_dict.dup
            _query_dict["offset"] = i * query.perPage
            request_bodies << _query_dict
          end

          responses = site.amc_request(bodies: request_bodies)
          html_bodies.concat(responses.map { |response| Nokogiri::HTML(response["body"]) })
        end

        # 全てのHTMLボディをパースしてページコレクションを作成
        pages = html_bodies.flat_map { |html_body| parse(site, html_body) }
        new(site: site, pages: pages)
      end

      # メソッドを定義する部分の修正
      def get_page_sources
        PageCollection.acquire_page_sources(@site, self)
      end

      def get_page_ids
        PageCollection.acquire_page_ids(@site, self)
      end

      def get_page_revisions
        PageCollection.acquire_page_revisions(@site, self)
      end

      def get_page_votes
        PageCollection.acquire_page_votes(@site, self)
      end

      def get_page_discuss
        PageCollection.acquire_page_discuss(@site, self)
      end

      def self.acquire_page_sources(site, pages)
        return pages if pages.empty?

        responses = site.amc_request(
          bodies: pages.map { |page| { "moduleName" => "viewsource/ViewSourceModule", "page_id" => page.id } }
        )

        pages.each_with_index do |page, index|
          body = responses[index]["body"]
          source = Nokogiri::HTML(body).at_css("div.page-source").text.strip
          page.source = PageSource.new(page: page, wiki_text: source)
        end

        pages
      end

      def self.acquire_page_ids(site, pages)
        target_pages = pages.reject(&:is_id_acquired?)
        return pages if target_pages.empty?

        responses = Wikidotrb::Util::RequestUtil.request(
          client: site.client,
          method: "GET",
          urls: target_pages.map { |page| "#{page.get_url}/norender/true/noredirect/true" }
        )

        responses.each_with_index do |response, index|
          source = response.body.to_s # Convert to string if necessary

          id_match = source&.match(/WIKIREQUEST\.info\.pageId = (\d+);/)

          unless id_match
            raise Wikidotrb::Common::Exceptions::UnexpectedException,
                  "Cannot find page id for: #{target_pages[index].fullname}, possibly an invalid response"
          end

          target_pages[index].id = id_match[1].to_i
        end

        pages
      end

      def self.acquire_page_revisions(site, pages)
        return pages if pages.empty?

        responses = site.amc_request(
          bodies: pages.map do |page|
            {
              "moduleName" => "history/PageRevisionListModule",
              "page_id" => page.id,
              "options" => { "all" => true },
              "perpage" => 100_000_000 # pagerを使わずに全て取得
            }
          end
        )

        responses.each_with_index do |response, index|
          body = response["body"]
          revs = []
          body_html = Nokogiri::HTML(body)

          body_html.css("table.page-history > tr[id^=revision-row-]").each do |rev_element|
            rev_id = rev_element["id"].gsub("revision-row-", "").to_i

            tds = rev_element.css("td")
            rev_no = tds[0].text.strip.gsub(".", "").to_i
            created_by = Wikidotrb::Util::Parser::UserParser.parse(site.client, tds[4].css("span.printuser").first)
            created_at = Wikidotrb::Util::Parser::ODateParser.parse(tds[5].css("span.odate").first)
            comment = tds[6].text.strip
            revs << PageRevision.new(
              page: pages[index],
              id: rev_id,
              rev_no: rev_no,
              created_by: created_by,
              created_at: created_at,
              comment: comment
            )
          end
          pages[index].revisions = revs
        end

        pages
      end

      def self.acquire_page_votes(site, pages)
        return pages if pages.empty?

        responses = site.amc_request(
          bodies: pages.map { |page| { "moduleName" => "pagerate/WhoRatedPageModule", "pageId" => page.id } }
        )

        responses.each_with_index do |response, index|
          body = response["body"]
          html = Nokogiri::HTML(body)
          user_elems = html.css("span.printuser")
          value_elems = html.css('span[style^="color"]')

          if user_elems.size != value_elems.size
            raise Wikidotrb::Common::Exceptions::UnexpectedException,
                  "User and value count mismatch"
          end

          users = user_elems.map { |user_elem| Wikidotrb::Util::Parser::UserParser.parse(site.client, user_elem) }
          values = value_elems.map do |value_elem|
            value = value_elem.text.strip
            if value == "+"
              1
            elsif value == "-"
              -1
            else
              value.to_i
            end
          end

          votes = users.zip(values).map { |user, vote| PageVote.new(page: pages[index], user: user, value: vote) }
          pages[index].votes = PageVoteCollection.new(page: pages[index], votes: votes)
        end

        pages
      end

      def self.acquire_page_discuss(site, pages)
        target_pages = pages.reject(&:is_discuss_acquired?)
        return pages if target_pages.empty?

        responses = site.amc_request(
          bodies: target_pages.map do |page|
            {
              "action" => "ForumAction",
              "event" => "createPageDiscussionThread",
              "page_id" => page.id,
              "moduleName" => "Empty"
            }
          end
        )

        target_pages.each_with_index do |page, index|
          page.discuss = ForumThread.new(site, responses[index]["thread_id"], page: page)
        end
      end
    end

    class Page
      attr_accessor :site, :fullname, :name, :category, :title, :children_count,
                    :comments_count, :size, :rating, :votes_count, :rating_percent,
                    :revisions_count, :parent_fullname, :tags, :created_by, :created_at,
                    :updated_by, :updated_at, :commented_by, :commented_at, :_id,
                    :_source, :_revisions, :_votes, :_discuss

      def initialize(site:, fullname:, name: "", category: "", title: "", children_count: 0, comments_count: 0, size: 0, rating: 0,
                     votes_count: 0, rating_percent: 0, revisions_count: 0, parent_fullname: "", tags: [], created_by: nil, created_at: nil,
                     updated_by: nil, updated_at: nil, commented_by: nil, commented_at: nil, _id: nil, _source: nil, _revisions: nil,
                     _votes: nil, _discuss: nil)
        @site = site
        @fullname = fullname
        @name = name
        @category = category
        @title = title
        @children_count = children_count
        @comments_count = comments_count
        @size = size
        @rating = rating
        @votes_count = votes_count
        @rating_percent = rating_percent
        @revisions_count = revisions_count
        @parent_fullname = parent_fullname
        @tags = tags
        @created_by = created_by
        @created_at = created_at
        @updated_by = updated_by
        @updated_at = updated_at
        @commented_by = commented_by
        @commented_at = commented_at
        @_id = _id
        @_source = _source
        @_revisions = _revisions
        @_votes = _votes
        @_discuss = _discuss
      end

      def discuss
        PageCollection.new(site: @site, pages: [self]).get_page_discuss if @_discuss.nil?
        @_discuss.update
        @_discuss
      end

      def discuss=(value)
        @_discuss = value
      end

      def is_discuss_acquired?
        !@_discuss.nil?
      end

      def get_url
        "#{@site.get_url}/#{@fullname}"
      end

      def id
        PageCollection.new(site: @site, pages: [self]).get_page_ids if @_id.nil?
        @_id
      end

      def id=(value)
        @_id = value
      end

      def is_id_acquired?
        !@_id.nil?
      end

      def source
        PageCollection.new(site: @site, pages: [self]).get_page_sources if @_source.nil?
        @_source
      end

      def source=(value)
        @_source = value
      end

      def revisions
        PageCollection.new(site: @site, pages: [self]).get_page_revisions if @_revisions.nil?
        PageRevisionCollection.new(page: self, revisions: @_revisions)
      end

      def revisions=(value)
        @_revisions = value
      end

      def latest_revision
        # revision_countとrev_noが一致するものを取得
        @revisions.each do |revision|
          return revision if revision.rev_no == @revisions_count
        end

        raise Wikidotrb::Common::Exceptions::NotFoundException, "Cannot find latest revision"
      end

      def votes
        PageCollection.new(site: @site, pages: [self]).get_page_votes if @_votes.nil?
        @_votes
      end

      def votes=(value)
        @_votes = value
      end

      def destroy
        @site.client.login_check
        @site.amc_request(bodies: [
                            {
                              action: "WikiPageAction",
                              event: "deletePage",
                              page_id: id,
                              moduleName: "Empty"
                            }
                          ])
      end

      def get_metas
        response_data = @site.amc_request(bodies: [{ pageId: id, moduleName: "edit/EditMetaModule" }])[0]
        body = response_data["body"]

        metas = {}
        body.scan(/&lt;meta name="([^"]+)" content="([^"]+)"/) do |meta|
          metas[meta[0]] = meta[1]
        end

        metas
      end

      def set_meta(name, value)
        @site.client.login_check
        @site.amc_request(bodies: [
                            {
                              metaName: name,
                              metaContent: value,
                              action: "WikiPageAction",
                              event: "saveMetaTag",
                              pageId: id,
                              moduleName: "edit/EditMetaModule"
                            }
                          ])
      end

      def delete_meta(name)
        @site.client.login_check
        @site.amc_request(bodies: [
                            {
                              metaName: name,
                              action: "WikiPageAction",
                              event: "deleteMetaTag",
                              pageId: id,
                              moduleName: "edit/EditMetaModule"
                            }
                          ])
      end

      def self.create_or_edit(site:, fullname:, page_id: nil, title: "", source: "", comment: "", force_edit: false, raise_on_exists: false)
        site.client.login_check

        page_lock_request_body = {
          mode: "page",
          wiki_page: fullname,
          moduleName: "edit/PageEditModule"
        }
        page_lock_request_body[:force_lock] = "yes" if force_edit

        # Requesting page lock
        page_lock_response_data = site.amc_request(bodies: [page_lock_request_body])[0]

        # Handling page lock errors
        if page_lock_response_data.nil? || page_lock_response_data["locked"] || page_lock_response_data["other_locks"]
          raise Wikidotrb::Common::Exceptions::TargetErrorException, "Page #{fullname} is locked or other locks exist"
        end

        is_exist = page_lock_response_data.key?("page_revision_id")

        raise Wikidotrb::Common::Exceptions::TargetExistsException, "Page #{fullname} already exists" if raise_on_exists && is_exist

        raise ArgumentError, "page_id must be specified when editing existing page" if is_exist && page_id.nil?

        lock_id = page_lock_response_data["lock_id"]
        lock_secret = page_lock_response_data["lock_secret"]
        page_revision_id = page_lock_response_data["page_revision_id"]

        edit_request_body = {
          action: "WikiPageAction",
          event: "savePage",
          moduleName: "Empty",
          mode: "page",
          lock_id: lock_id,
          lock_secret: lock_secret,
          revision_id: page_revision_id || "",
          wiki_page: fullname,
          page_id: page_id || "",
          title: title,
          source: source,
          comments: comment
        }

        response_data = site.amc_request(bodies: [edit_request_body])[0]

        unless response_data && response_data["status"] == "ok"
          error_status = response_data.nil? ? "no_response" : response_data["status"]
          raise Wikidotrb::Common::Exceptions::WikidotStatusCodeException.new(
            "Failed to create or edit page: #{fullname}",
            error_status
          )
        end

        # Confirming page creation
        res = PageCollection.search_pages(site, Wikidotrb::Module::SearchPagesQuery.new(fullname: fullname))
        raise Wikidotrb::Common::Exceptions::NotFoundException, "Page creation failed: #{fullname}" if res.empty?

        res[0]
      end

      def edit(title: nil, source: nil, comment: nil, force_edit: false)
        title ||= @title
        source ||= @source.wiki_text
        comment ||= ""

        Page.create_or_edit(
          site: @site,
          fullname: @fullname,
          page_id: id,
          title: title,
          source: source,
          comment: comment,
          force_edit: force_edit
        )
      end

      def set_tags(tags)
        @site.client.login_check
        @site.amc_request(bodies: [
                            {
                              tags: tags.join(" "),
                              action: "WikiPageAction",
                              event: "saveTags",
                              pageId: id,
                              moduleName: "Empty"
                            }
                          ])
      end
    end
  end
end
