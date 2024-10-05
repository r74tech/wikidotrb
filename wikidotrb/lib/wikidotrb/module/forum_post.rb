require 'nokogiri'
require 'date'
require_relative '../common/exceptions'

module Wikidotrb
  module Module
    class ForumPostCollection < Array
      attr_accessor :thread

      # 初期化メソッド
      # @param thread [ForumThread] スレッドオブジェクト
      # @param posts [Array<ForumPost>] 投稿オブジェクトのリスト
      def initialize(thread:, posts: [])
        super(posts)
        @thread = thread
      end

      # イテレーションをオーバーライド
      def each(&block)
        super(&block)
      end

      # IDで投稿を検索する
      # @param target_id [Integer] 投稿ID
      # @return [ForumPost, nil] 投稿が見つかった場合はForumPostオブジェクト、見つからなければnil
      def find(target_id)
        find { |post| post.id == target_id }
      end

      # 親投稿を取得して設定する
      # @param thread [ForumThread] スレッドオブジェクト
      # @param posts [Array<ForumPost>] 投稿オブジェクトのリスト
      # @return [Array<ForumPost>] 更新された投稿のリスト
      def self.acquire_parent_post(thread:, posts:)
        return posts if posts.empty?

        posts.each { |post| post.parent = thread.get(post.parent_id) }
        posts
      end

      # 親投稿をリビジョンに取得する
      def get_parent_post
        ForumPostCollection.acquire_parent_post(thread: @thread, posts: self)
      end

      # 投稿情報を取得して設定する
      # @param thread [ForumThread] スレッドオブジェクト
      # @param posts [Array<ForumPost>] 投稿オブジェクトのリスト
      # @return [Array<ForumPost>] 更新された投稿のリスト
      def self.acquire_post_info(thread:, posts:)
        return posts if posts.empty?

        responses = thread.site.amc_request(
          posts.map do |post|
            {
              "postId" => post.id,
              "threadId" => thread.id,
              "moduleName" => "forum/sub/ForumEditPostFormModule"
            }
          end
        )

        responses.each_with_index do |response, index|
          html = Nokogiri::HTML(response.body.to_s)
          title = html.at_css("input#np-title")&.text&.strip
          source = html.at_css("textarea#np-text")&.text&.strip
          posts[index].title = title
          posts[index].source = source
        end

        posts
      end

      # 投稿情報をリビジョンに取得する
      def get_post_info
        ForumPostCollection.acquire_post_info(thread: @thread, posts: self)
      end
    end

    class ForumPost
      attr_accessor :site, :id, :forum, :thread, :parent_id, :created_by, :created_at, :edited_by, :edited_at, :source_text, :source_ele
      attr_reader :parent, :title, :source

      # 初期化メソッド
      def initialize(site:, id:, forum:, thread: nil, parent_id: nil, created_by: nil, created_at: nil, edited_by: nil, edited_at: nil, source_text: nil, source_ele: nil)
        @site = site
        @id = id
        @forum = forum
        @thread = thread
        @parent_id = parent_id
        @created_by = created_by
        @created_at = created_at
        @edited_by = edited_by
        @edited_at = edited_at
        @source_text = source_text
        @source_ele = source_ele
        @parent = nil
        @title = nil
        @source = nil
      end

      # 親投稿を設定する
      def parent=(value)
        @parent = value
      end

      # タイトルを設定する
      def title=(value)
        @title = value
      end

      # ソースを設定する
      def source=(value)
        @source = value
      end

      # 投稿のURLを取得する
      def get_url
        "#{@thread.get_url}#post-#{@id}"
      end

      # 親投稿のゲッターメソッド
      def parent
        unless @parent
          ForumPostCollection.new(thread: @thread, posts: [self]).get_parent_post
        end
        @parent
      end

      # タイトルのゲッターメソッド
      def title
        unless @title
          ForumPostCollection.new(thread: @thread, posts: [self]).get_post_info
        end
        @title
      end

      # ソースのゲッターメソッド
      def source
        unless @source
          ForumPostCollection.new(thread: @thread, posts: [self]).get_post_info
        end
        @source
      end

      # 投稿への返信を行う
      def reply(title: "", source: "")
        client = @site.client
        client.login_check
        raise Wikidotrb::Common::UnexpectedException, "Post body can not be left empty." if source == ""

        response = @site.amc_request(
          [
            {
              "parentId" => @id,
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
          thread: @thread,
          parent_id: @id,
          created_by: client.user.get(client.username),
          created_at: DateTime.parse(body["CURRENT_TIMESTAMP"])
        )
      end

      # 投稿の編集を行う
      def edit(title: nil, source: nil)
        client = @site.client
        client.login_check

        return self if title.nil? && source.nil?
        raise Wikidotrb::Common::UnexpectedException, "Post source can not be left empty." if source == ""

        begin
          response = @site.amc_request(
            [
              {
                "postId" => @id,
                "threadId" => @thread.id,
                "moduleName" => "forum/sub/ForumEditPostFormModule"
              }
            ]
          ).first
          html = Nokogiri::HTML(response.body.to_s)
          current_id = html.at_css("form#edit-post-form>input")[1].get("value").to_i

          @site.amc_request(
            [
              {
                "postId" => @id,
                "currentRevisionId" => current_id,
                "title" => title || @title,
                "source" => source || @source,
                "action" => "ForumAction",
                "event" => "saveEditPost",
                "moduleName" => "Empty"
              }
            ]
          )
        rescue Wikidotrb::Common::WikidotStatusCodeException
          return self
        end

        @edited_by = client.user.get(client.username)
        @edited_at = DateTime.now
        @title = title || @title
        @source = source || @source

        self
      end

      # 投稿の削除を行う
      def destroy
        @site.client.login_check
        @site.amc_request(
          [
            {
              "postId" => @id,
              "action" => "ForumAction",
              "event" => "deletePost",
              "moduleName" => "Empty"
            }
          ]
        )
      end
    end
  end
end
