require 'nokogiri'
require 'date'
require_relative 'forum_thread'

module Wikidotrb
  module Module
    class ForumCategoryCollection < Array
      attr_accessor :forum

      # 初期化メソッド
      # @param forum [Forum] フォーラムオブジェクト
      # @param categories [Array<ForumCategory>] カテゴリーのリスト
      def initialize(forum:, categories: [])
        super(categories)
        @forum = forum
      end

      # イテレーションをオーバーライド
      def each(&block)
        super(&block)
      end

      # サイトとフォーラムからカテゴリを取得
      # @param site [Site] サイトオブジェクト
      # @param forum [Forum] フォーラムオブジェクト
      def self.get_categories(site:, forum:)
        categories = []

        forum.groups.each do |group|
          categories.concat(group.categories)
        end

        forum._categories = ForumCategoryCollection.new(forum: forum, categories: categories)
      end

      # IDまたはタイトルからカテゴリを検索
      # @param id [Integer] カテゴリID
      # @param title [String] カテゴリのタイトル
      # @return [ForumCategory, nil] 一致するカテゴリ
      def find(id: nil, title: nil)
        find do |category|
          (id.nil? || category.id == id) && (title.nil? || category.title == title)
        end
      end

      # カテゴリ情報を取得して更新する
      # @param forum [Forum] フォーラムオブジェクト
      # @param categories [Array<ForumCategory>] カテゴリーのリスト
      # @return [Array<ForumCategory>] 更新されたカテゴリのリスト
      def self.acquire_update(forum:, categories:)
        return categories if categories.empty?

        responses = forum.site.amc_request(
          categories.map { |category| { "c" => category.id, "moduleName" => "forum/ForumViewCategoryModule" } }
        )

        responses.each_with_index do |response, index|
          category = categories[index]
          html = Nokogiri::HTML(response.body.to_s)
          statistics = html.at_css("div.statistics").text
          description = html.at_css("div.description-block").text.strip
          info = html.at_css("div.forum-breadcrumbs").text.match(/([ \S]*) \/ ([ \S]*)/)
          counts = statistics.scan(/\d+/).map(&:to_i)

          category.last = nil if category.posts_counts != counts[1]
          category.description = description.match(/[ \S]*$/)[0]
          category.threads_counts, category.posts_counts = counts
          category.group = category.forum.groups.find(info[1])
          category.title = info[2]
          pager_no = html.at_css("span.pager-no")
          category.pagerno = pager_no.nil? ? 1 : pager_no.text.match(/of (\d+)/)[1].to_i
        end

        categories
      end

      # カテゴリ情報を更新
      def update
        ForumCategoryCollection.acquire_update(forum: @forum, categories: self)
      end
    end

    class ForumCategory
      attr_accessor :site, :id, :forum, :title, :description, :group, :threads_counts, :posts_counts, :pagerno
      attr_reader :last

      def initialize(site:, id:, forum:, title: nil, description: nil, group: nil, threads_counts: nil, posts_counts: nil, pagerno: nil, last_thread_id: nil, last_post_id: nil)
        @site = site
        @id = id
        @forum = forum
        @title = title
        @description = description
        @group = group
        @threads_counts = threads_counts
        @posts_counts = posts_counts
        @pagerno = pagerno
        @_last_thread_id = last_thread_id
        @_last_post_id = last_post_id
        @_last = nil
      end

      # カテゴリのURLを取得
      def get_url
        "#{@site.get_url}/forum/c-#{@id}"
      end

      # カテゴリを更新
      def update
        ForumCategoryCollection.new(forum: @forum, categories: [self]).update.first
      end

      # 最後の投稿を取得
      def last
        if @_last_thread_id && @_last_post_id && @_last.nil?
          @_last = @forum.thread.get(@_last_thread_id).get(@_last_post_id)
        end
        @_last
      end

      # 最後の投稿を設定
      def last=(value)
        @_last = value
      end

      # スレッドのコレクションを取得する
      # @return [ForumThreadCollection] スレッドオブジェクトのコレクション
      def threads
        client = @site.client
        update
        responses = @site.amc_request(
          (1..@pagerno).map { |no| { "p" => no, "c" => @id, "moduleName" => "forum/ForumViewCategoryModule" } }
        )

        threads = []

        responses.each do |response|
          html = Nokogiri::HTML(response.body.to_s)
          html.css("table.table tr.head~tr").each do |info|
            title = info.at_css("div.title a")
            thread_id = title["href"].match(/t-(\d+)/)[1].to_i
            description = info.at_css("div.description").text.strip
            user = info.at_css("span.printuser")
            odate = info.at_css("span.odate")
            posts_count = info.at_css("td.posts").text.to_i
            last_id = info.at_css("td.last>a")
            post_id = last_id.nil? ? nil : last_id["href"].match(/post-(\d+)/)[1].to_i

            thread = ForumThread.new(
              site: @site,
              id: thread_id,
              forum: @forum,
              title: title.text.strip,
              description: description,
              created_by: user_parser(client, user),
              created_at: odate_parser(odate),
              posts_counts: posts_count,
              _last_post_id: post_id
            )

            threads << thread
          end
        end

        ForumThreadCollection.new(forum: @forum, threads: threads)
      end

      # 新しいスレッドを作成
      def new_thread(title:, source:, description: "")
        client = @site.client
        client.login_check

        response = @site.amc_request(
          [
            {
              "category_id" => @id,
              "title" => title,
              "description" => description,
              "source" => source,
              "action" => "ForumAction",
              "event" => "newThread"
            }
          ]
        ).first

        body = JSON.parse(response.body.to_s)

        ForumThread.new(
          site: @site,
          id: body["threadId"].to_i,
          forum: @forum,
          category: self,
          title: title,
          description: description,
          created_by: client.user.get(client.username),
          created_at: DateTime.parse(body["CURRENT_TIMESTAMP"]),
          posts_counts: 1
        )
      end
    end
  end
end
