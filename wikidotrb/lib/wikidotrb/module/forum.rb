require_relative 'forum_category'
require_relative 'forum_group'
require_relative 'forum_thread'

module Wikidotrb
  module Module
    class ForumCategoryMethods
      # 初期化メソッド
      # @param forum [Forum] フォーラムオブジェクト
      def initialize(forum)
        @forum = forum
      end

      # カテゴリをIDから取得
      # @param id [Integer] カテゴリID
      # @return [ForumCategory] 更新されたカテゴリ
      def get(id)
        category = ForumCategory.new(
          site: @forum.site,
          id: id,
          forum: @forum
        )
        category.update
      end
    end

    class ForumThreadMethods
      # 初期化メソッド
      # @param forum [Forum] フォーラムオブジェクト
      def initialize(forum)
        @forum = forum
      end

      # スレッドをIDから取得
      # @param id [Integer] スレッドID
      # @return [ForumThread] 更新されたスレッド
      def get(id)
        thread = ForumThread.new(
          site: @forum.site,
          id: id,
          forum: @forum
        )
        thread.update
      end
    end

    class Forum
      attr_accessor :site, :_groups, :_categories

      # 初期化メソッド
      # @param site [Site] サイトオブジェクト
      def initialize(site:)
        @site = site
        @name = 'Forum'
        @_groups = nil
        @_categories = nil
        @category = ForumCategoryMethods.new(self)
        @thread = ForumThreadMethods.new(self)
      end

      # カテゴリメソッドオブジェクトを取得
      # @return [ForumCategoryMethods] カテゴリメソッド
      def category
        @category
      end

      # スレッドメソッドオブジェクトを取得
      # @return [ForumThreadMethods] スレッドメソッド
      def thread
        @thread
      end

      # フォーラムのURLを取得
      # @return [String] フォーラムのURL
      def get_url
        "#{@site.get_url}/forum/start"
      end

      # グループのプロパティ
      # @return [ForumGroupCollection] グループコレクション
      def groups
        if @_groups.nil?
          ForumGroupCollection.get_groups(site: @site, forum: self)
        end
        @_groups
      end

      # カテゴリのプロパティ
      # @return [ForumCategoryCollection] カテゴリコレクション
      def categories
        if @_categories.nil?
          ForumCategoryCollection.get_categories(site: @site, forum: self)
        end
        @_categories
      end
    end
  end
end
