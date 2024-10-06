require 'spec_helper'
require 'wikidotrb/module/site'

RSpec.describe Wikidotrb::Module::Site do
  let(:username) { RSpec.configuration.test_config['username'] }
  let(:password) { RSpec.configuration.test_config['password'] }
  let(:site_domain) { RSpec.configuration.test_config['site'] }
  let(:client) { Wikidotrb::Module::Client.new(username: username, password: password) }
  let(:site) { Wikidotrb::Module::Site.from_unix_name(client: client, unix_name: site_domain) }
  
  # 新しいページに関する情報を定義
  let(:new_page_fullname) { "new-page" }
  let(:page_title) { "Test Page Title" }
  let(:page_source) { "This is a test page." }

  describe '#from_unix_name' do
    it 'UNIX名から正しいサイトオブジェクトを取得できる' do
      expect(site.domain).to eq("#{site_domain}.wikidot.com")
      expect(site.client).to eq(client)
      expect(site.unix_name).to eq(site_domain)
      expect(site.id).not_to be_nil
    end

    it '存在しないサイトの場合にNotFoundExceptionが発生する' do
      expect {
        Wikidotrb::Module::Site.from_unix_name(client: client, unix_name: 'non_existing_site')
      }.to raise_error(Wikidotrb::Common::Exceptions::NotFoundException)
    end
  end

  describe 'SitePagesMethods' do
    it 'ページを検索できること' do
      pages = site.pages.search(category: '*')
      expect(pages).to be_a_kind_of(Wikidotrb::Module::PageCollection)
    end
  end

  describe 'SitePageMethods' do
    before(:all) do
      # 事前にページをキャッシュして作成
      @cached_page = nil
    end

    after(:all) do
      # キャッシュされたページが存在すれば削除
      if @cached_page
        @cached_page.destroy
        @cached_page = nil
      end
    end

    context '#get' do
      it '存在するページを取得できる' do
        page = site.page.get("start", raise_when_not_found: false)
        expect(page).to be_a_kind_of(Wikidotrb::Module::Page)
      end

      it '存在しないページを取得しようとした場合にnilを返す' do
        page = site.page.get("non_existing_page", raise_when_not_found: false)
        expect(page).to be_nil
      end

      it '存在しないページを取得しようとした場合に例外を発生する' do
        expect {
          site.page.get("non_existing_page")
        }.to raise_error(Wikidotrb::Common::Exceptions::NotFoundException)
      end
    end

    context '#create' do
      it '新しいページを作成できる' do
        unless @cached_page
          @cached_page = site.page.create(
            fullname: new_page_fullname,
            title: page_title,
            source: page_source
          )
        end
        expect(@cached_page.title).to eq(page_title)
        expect(@cached_page.source.wiki_text).to eq(page_source)
      end

      it '既存のページを作成しようとするとエラーが発生する' do
        # キャッシュされたページを利用して検証
        expect {
          site.page.create(
            fullname: new_page_fullname,
            title: page_title,
            source: page_source
          )
        }.to raise_error(Wikidotrb::Common::Exceptions::TargetExistsException)
      end

      it '既存のページを強制的に上書きできない' do
        # キャッシュされたページを利用して強制上書き
        expect {
          site.page.create(
            fullname: new_page_fullname,
            title: "New Title",
            source: "New Content",
            force_edit: true
          )
        }.to raise_error(Wikidotrb::Common::Exceptions::TargetExistsException)
      end
    end
  end

  describe '#get_applications' do
    it 'サイトへの未処理の参加申請を取得できること' do
      applications = site.get_applications
      expect(applications).to be_a_kind_of(Array)
    end
  end

  describe '#invite_user' do
    let(:test_user) { client.user.get(username, raise_when_not_found: false) }

    it '自分自身は招待できない' do
      expect {
        site.invite_user(user: test_user, text: "You are invited!")
      }.to raise_error(Wikidotrb::Common::Exceptions::TargetErrorException)
    end
  end

  describe '#get_url' do
    it 'サイトのURLが正しく取得できること' do
      expect(site.get_url).to eq("http#{site.ssl_supported ? 's' : ''}://#{site.domain}")
    end
  end
end
