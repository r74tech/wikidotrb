require 'nokogiri'
require 'date'
require_relative '../common/exceptions'
require_relative 'forum_post'

module Wikidotrb
  module Module
    class ForumThreadCollection < Array
      attr_accessor :forum

      # 初期化メソッド
      # @param forum [Forum] フォーラムオブジェクト
      # @param threads [Array<ForumThread>] スレッドのリスト
      def initialize(forum:, threads: [])
        super(threads)
        @forum = forum
      end

      # イテレーションをオーバーライド
      def each(&block)
        super(&block)
      end

      # スレッド情報を取得して更新する
      # @param forum [Forum] フォーラムオブジェクト
      # @param threads [Array<ForumThread>] スレッドのリスト
      # @return [Array<ForumThread>] 更新されたスレッドのリスト
      def self.acquire_update(forum:, threads:)
        return threads if threads.empty?

        client = forum.site.client
        responses = forum.site.amc_request(
          threads.map { |thread| { "t" => thread.id, "moduleName" => "forum/ForumViewThreadModule" } }
        )

        responses.each_with_index do |response, index|
          thread = threads[index]
          html = Nokogiri::HTML(response.body.to_s)
          statistics = html.at_css("div.statistics")
          user = statistics.at_css("span.printuser")
          odate = statistics.at_css("span.odate")
          category_url = html.css("div.forum-breadcrumbs a")[1]["href"]
          category_id = category_url.match(/c-(\d+)/)[1]
          title = html.at_css("div.forum-breadcrumbs").text.strip
          counts = statistics.text.scan(/\n.+\D(\d+)/).last.first.to_i

          thread.title = title.match(/»([ \S]*)$/)[1].strip
          thread.category = thread.forum.category.get(category_id.to_i)
          description_block = html.at_css("div.description-block div.head")
          thread.description = description_block.nil? ? "" : html.at_css("div.description-block").text.strip.match(/[ \S]+$/).to_s

          thread.last = nil if thread.posts_counts != counts
          thread.posts_counts = counts
          thread.created_by = user_parser(client, user)
          thread.created_at = odate_parser(odate)

          pager_no = html.at_css("span.pager-no")
          thread.pagerno = pager_no.nil? ? 1 : pager_no.text.match(/of (\d+)/)[1].to_i

          page_ele = html.at_css("div.description-block>a")
          if page_ele
            thread.page = thread.site.page.get(page_ele["href"][1..-1])
            thread.page.discuss = thread
          end
        end

        threads
      end

      # スレッドを更新する
      def update
        ForumThreadCollection.acquire_update(forum: @forum, threads: self)
      end
    end

    class ForumThread
      attr_accessor :site, :id, :forum, :category, :title, :description, :created_by, :created_at, :posts_counts, :page, :pagerno
      attr_reader :last

      def initialize(site:, id:, forum:, category: nil, title: nil, description: nil, created_by: nil, created_at: nil, posts_counts: nil, page: nil, pagerno: nil, last_post_id: nil)
        @site = site
        @id = id
        @forum = forum
        @category = category
        @title = title
        @description = description
        @created_by = created_by
        @created_at = created_at
        @posts_counts = posts_counts
        @page = page
        @pagerno = pagerno
        @_last_post_id = last_post_id
        @_last = nil
      end

      # 最後の投稿の取得
      def last
        if @_last_post_id && @_last.nil?
          update
          @_last = get(@_last_post_id)
        end
        @_last
      end

      # 最後の投稿を設定
      def last=(value)
        @_last = value
      end

      # 投稿のコレクションを取得する
      # @return [ForumPostCollection] 投稿オブジェクトのコレクション
      def posts
        client = @site.client
        responses = @site.amc_request(
          (1..@pagerno).map { |no| { "pagerNo" => no, "t" => @id, "order" => "", "moduleName" => "forum/ForumViewThreadPostsModule" } }
        )

        posts = []

        responses.each do |response|
          html = Nokogiri::HTML(response.body.to_s)
          html.css("div.post").each do |post|
            cuser = post.at_css("div.info span.printuser")
            codate = post.at_css("div.info span.odate")
            parent = post.parent["id"]
            parent_id = parent != "thread-container-posts" ? parent.match(/fpc-(\d+)/)[1].to_i : nil
            euser = post.at_css("div.changes span.printuser")
            eodate = post.at_css("div.changes span.odate a")

            posts << ForumPost.new(
              site: @site,
              id: post["id"].match(/post-(\d+)/)[1].to_i,
              forum: @forum,
              thread: self,
              _title: post.at_css("div.title").text.strip,
              parent_id: parent_id,
              created_by: user_parser(client, cuser),
              created_at: odate_parser(codate),
              edited_by: euser.nil? ? nil : client.user.get(euser.text),
              edited_at: eodate.nil? ? nil : odate_parser(eodate),
              source_ele: post.at_css("div.content"),
              source_text: post.at_css("div.content").text.strip
            )
          end
        end

        ForumPostCollection.new(thread: self, posts: posts)
      end

      # スレッドのURLを取得する
      def get_url
        "#{@site.get_url}/forum/t-#{@id}"
      end

      # スレッドを更新する
      def update
        ForumThreadCollection.new(forum: @forum, threads: [self]).update.first
      end

      # スレッドの編集
      def edit(title: nil, description: nil)
        @site.client.login_check
        raise Wikidotrb::Common::UnexpectedException, "Title can not be left empty." if title == ""

        if @page
          raise Wikidotrb::Common::UnexpectedException, "Page's discussion can not be edited."
        end

        return self if title.nil? && description.nil?

        @site.amc_request(
          [
            {
              "threadId" => @id,
              "title" => @title.nil? ? title : @title,
              "description" => description.nil? ? @description : description,
              "action" => "ForumAction",
              "event" => "saveThreadMeta",
              "moduleName" => "Empty"
            }
          ]
        )

        @title = title.nil? ? @title : title
        @description = description.nil? ? @description : description

        self
      end

      # スレッドのカテゴリ移動
      def move_to(category_id)
        @site.client.login_check
        @site.amc_request(
          [
            {
              "categoryId" => category_id,
              "threadId" => @id,
              "action" => "ForumAction",
              "event" => "moveThread",
              "moduleName" => "Empty"
            }
          ]
        )
      end

      # スレッドのロック
      def lock
        @site.client.login_check
        @site.amc_request(
          [
            {
              "threadId" => @id,
              "block" => "true",
              "action" => "ForumAction",
              "event" => "saveBlock",
              "moduleName" => "Empty"
            }
          ]
        )
        self
      end

      # スレッドのアンロック
      def unlock
        @site.client.login_check
        @site.amc_request(
          [
            {
              "threadId" => @id,
              "action" => "ForumAction",
              "event" => "saveBlock",
              "moduleName" => "Empty"
            }
          ]
        )
        self
      end

      # スレッドがロックされているか確認
      def locked?
        @site.client.login_check
        response = @site.amc_request(
          [
            {
              "threadId" => @id,
              "moduleName" => "forum/sub/ForumEditThreadBlockModule"
            }
          ]
        ).first

        html = Nokogiri::HTML(response.body.to_s)
        checked = html.at_css("input.checkbox")["checked"]

        !checked.nil?
      end

      # スレッドを固定する
      def stick
        @site.client.login_check
        @site.amc_request(
          [
            {
              "threadId" => @id,
              "sticky" => "true",
              "action" => "ForumAction",
              "event" => "saveSticky",
              "moduleName" => "Empty"
            }
          ]
        )
        self
      end

      # スレッドの固定を解除する
      def unstick
        @site.client.login_check
        @site.amc_request(
          [
            {
              "threadId" => @id,
              "action" => "ForumAction",
              "event" => "saveSticky",
              "moduleName" => "Empty"
            }
          ]
        )
        self
      end

      # スレッドが固定されているか確認
      def sticked?
        @site.client.login_check
        response = @site.amc_request(
          [
            {
              "threadId" => @id,
              "moduleName" => "forum/sub/ForumEditThreadStickinessModule"
            }
          ]
        ).first

        html = Nokogiri::HTML(response.body.to_s)
        checked = html.at_css("input.checkbox")["checked"]

        !checked.nil?
      end

      # 新しい投稿を作成する
      def new_post(title: "", source: "", parent_id: "")
        client = @site.client
        client.login_check
        raise Wikidotrb::Common::UnexpectedException, "Post body can not be left empty." if source == ""

        response = @site.amc_request(
          [
            {
              "parentId" => parent_id,
              "title" => title,
              "source" => source,
              "action" => "ForumAction",
              "event" => "savePost"
            }
          ]
        ).first

        body = JSON.parse(response.body.to_s)

        ForumPost.new(
          site: @site,
          id: body["postId"].to_i,
          forum: @forum,
          title: title,
          source: source,
          thread: self,
          parent_id: parent_id.empty? ? nil : parent_id.to_i,
          created_by: client.user.get(client.username),
          created_at: DateTime.parse(body["CURRENT_TIMESTAMP"])
        )
      end

      # 投稿を取得する
      def get(post_id)
        posts.find { |post| post.id == post_id }
      end
    end
  end
end
