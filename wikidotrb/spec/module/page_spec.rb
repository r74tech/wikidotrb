# frozen_string_literal: true

require "spec_helper"
require "wikidotrb/module/client"
require "wikidotrb/module/site"
require "wikidotrb/module/page"

RSpec.describe Wikidotrb::Module::Page do
  let(:username) { RSpec.configuration.test_config["username"] }
  let(:password) { RSpec.configuration.test_config["password"] }
  let(:site_domain) { RSpec.configuration.test_config["site"] }
  let(:test_page_title) { "Test Page Title" }
  let(:test_page_source) { "This is a test page." }
  let(:client) { Wikidotrb::Module::Client.new(username: username, password: password) }
  let(:site) { client.site.get(site_domain) }

  before(:all) do
    # Assign the test_page_name once before all examples run
    @test_page_name = "test-page-#{Time.now.to_i}"
  end

  describe "Page management" do
    before(:each) do
      # テスト開始前にログイン確認
      expect(client.is_logged_in).to be true
      expect(client.username).to eq(username)
      # テスト開始前にサイトオブジェクトを取得
      expect(site).not_to be_nil

      # Ensure the page does not exist before each test
      begin
        existing_page = site.page.get(@test_page_name)
        existing_page&.destroy
      rescue Wikidotrb::Common::Exceptions::NotFoundException
        # ページが存在しない場合は無視
      end
    end

    after(:each) do
      # Ensure cleanup after each test
      begin
        page = site.page.get(@test_page_name)
        page&.destroy
      rescue Wikidotrb::Common::Exceptions::NotFoundException
        # ページが存在しない場合は無視
      end

      # 各テストケース終了後にクライアントをログアウト
      client.finalize if client.is_logged_in
    end

    context "Creating a page" do
      it "新しいページを作成できること" do
        page = site.page.create(
          fullname: @test_page_name,
          title: test_page_title,
          source: test_page_source
        )
        expect(page.fullname).to eq(@test_page_name)
        expect(page.title).to eq(test_page_title)
        expect(page.source.wiki_text).to eq(test_page_source)
      end
    end

    context "Editing a page" do
      it "既存のページを編集できること" do
        # ページが存在するか確認し、存在しない場合は作成
        page = site.page.get(@test_page_name, raise_when_not_found: false)
        page ||= site.page.create(
          fullname: @test_page_name,
          title: test_page_title,
          source: test_page_source
        )

        # ページを編集
        new_source = "This is the updated content of the page."
        page.edit(source: new_source, comment: "Updating the test page")

        # 編集が正しく反映されているか確認
        updated_page = site.page.get(@test_page_name)
        expect(updated_page.source.wiki_text).to eq(new_source)
      end
    end

    context "Searching for pages" do
      it "指定したクエリに基づいてページを検索できること" do
        # ページ作成
        site.page.create(
          fullname: @test_page_name,
          title: test_page_title,
          source: test_page_source
        )

        pages = site.pages.search(
          category: "*",
          name: @test_page_name
        )
        expect(pages).not_to be_empty
        expect(pages.first.fullname).to eq(@test_page_name)
      end
    end

    context "Deleting a page" do
      it "既存のページを削除できること" do
        # ページ作成
        site.page.create(
          fullname: @test_page_name,
          title: test_page_title,
          source: test_page_source
        )

        page = site.page.get(@test_page_name)
        expect(page).not_to be_nil

        # ページを削除
        page.destroy

        # 削除後の存在確認
        expect do
          site.page.get(@test_page_name)
        end.to raise_error(Wikidotrb::Common::Exceptions::NotFoundException)
      end
    end
  end

  describe "Page voting" do
    let(:disabled_vote_page_name) { "disablevote:vote" }
    let(:anonymous_vote_page_name) { "anonymouslyvote:vote" }
    let(:user_vote_page_name) { "plusminus:vote" }
    let(:plusonly_vote_page_name) { "plusonly:vote" }
    let(:stars_vote_page_name) { "stars:vote" }

    context "Voteが無効化されているページ" do
      it "Voteを取得できること" do
        page = site.page.get(disabled_vote_page_name)
        expect(page.votes_count).to eq(0)
        expect(page.rating).to eq(0)
        expect(page.rating_percent).to eq(nil)
      end
    end

    context "匿名投票が有効化されているページ" do
      it "Voteを取得できること" do
        page = site.page.get(anonymous_vote_page_name)
        expect(page.votes_count).to eq(3)
        expect(page.rating).to eq(3)
        expect(page.rating_percent).to eq(nil)
      end

      it "誰が投票したかを取得できること" do
        page = site.page.get(anonymous_vote_page_name)
        votes = page.votes

        votes.each do |vote|
          expect(vote.user).not_to be_nil
          expect(vote.value).not_to be_nil
        end
      end
    end

    context "ユーザー投票(+-)が有効化されているページ" do
      it "Voteを取得できること" do
        page = site.page.get(user_vote_page_name)
        expect(page.votes_count).to eq(3)
        expect(page.rating).to eq(1)
        expect(page.rating_percent).to eq(nil)
      end

      it "誰が投票したかを取得できること" do
        page = site.page.get(user_vote_page_name)
        votes = page.votes

        votes.each do |vote|
          expect(vote.user).not_to be_nil
          expect(vote.value).not_to be_nil
        end
      end
    end

    context "ユーザー投票(+only)が有効化されているページ" do
      it "Voteを取得できること" do
        page = site.page.get(plusonly_vote_page_name)
        expect(page.votes_count).to eq(3)
        expect(page.rating).to eq(3)
        expect(page.rating_percent).to eq(nil)
      end

      it "誰が投票したかを取得できること" do
        page = site.page.get(plusonly_vote_page_name)
        votes = page.votes

        votes.each do |vote|
          expect(vote.user).not_to be_nil
          expect(vote.value).not_to be_nil
        end
      end
    end
  end
end
