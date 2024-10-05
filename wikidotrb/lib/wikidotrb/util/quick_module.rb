require 'httpx'
require 'json'

# QMCUser構造体の定義
QMCUser = Struct.new(:id, :name, keyword_init: true)

# QMCPage構造体の定義
QMCPage = Struct.new(:title, :unix_name, keyword_init: true)

class QuickModule
  # リクエストを送信する
  # @param module_name [String] モジュール名
  # @param site_id [Integer] サイトID
  # @param query [String] クエリ
  # @return [Hash] レスポンスのJSONパース結果
  def self._request(module_name:, site_id:, query:)
    # 有効なモジュール名か確認
    unless ["MemberLookupQModule", "UserLookupQModule", "PageLookupQModule"].include?(module_name)
      raise ArgumentError, 'Invalid module name'
    end

    # リクエストURLの構築
    url = "https://www.wikidot.com/quickmodule.php?module=#{module_name}&s=#{site_id}&q=#{query}"

    # HTTPリクエストの送信
    response = HTTPX.get(url, timeout: { operation: 300 })

    # ステータスコードのチェック
    if response.status == 500
      raise ArgumentError, 'Site is not found'
    end

    # JSONレスポンスのパース
    JSON.parse(response.body.to_s)
  end

  # メンバーを検索する
  # @param site_id [Integer] サイトID
  # @param query [String] クエリ
  # @return [Array<QMCUser>] ユーザーのリスト
  def self.member_lookup(site_id:, query:)
    users = _request(module_name: "MemberLookupQModule", site_id: site_id, query: query)["users"]
    users.map { |user| QMCUser.new(id: user["user_id"].to_i, name: user["name"]) }
  end

  # ユーザーを検索する
  # @param site_id [Integer] サイトID
  # @param query [String] クエリ
  # @return [Array<QMCUser>] ユーザーのリスト
  def self.user_lookup(site_id:, query:)
    users = _request(module_name: "UserLookupQModule", site_id: site_id, query: query)["users"]
    users.map { |user| QMCUser.new(id: user["user_id"].to_i, name: user["name"]) }
  end

  # ページを検索する
  # @param site_id [Integer] サイトID
  # @param query [String] クエリ
  # @return [Array<QMCPage>] ページのリスト
  def self.page_lookup(site_id:, query:)
    pages = _request(module_name: "PageLookupQModule", site_id: site_id, query: query)["pages"]
    pages.map { |page| QMCPage.new(title: page["title"], unix_name: page["unix_name"]) }
  end
end
