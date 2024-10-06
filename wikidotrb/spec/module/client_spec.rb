require 'spec_helper'
require 'wikidotrb/module/client'

RSpec.describe Wikidotrb::Module::Client do
  let(:username) { RSpec.configuration.test_config['username'] }
  let(:password) { RSpec.configuration.test_config['password'] }
  let(:site_domain) { RSpec.configuration.test_config['site'] }

  let(:client) { described_class.new(username: username, password: password) }

  describe '#initialize' do
    it '指定された認証情報でログインできる' do
      expect(client.is_logged_in).to be true
      expect(client.username).to eq(username)
    end
  end

  describe 'ClientUserMethods' do
    it 'ユーザー名からユーザーオブジェクトを取得できること' do
      user = client.user.get(username, raise_when_not_found: true)
      expect(user.name).to eq(username)
    end

    it 'ユーザー名リストからユーザーオブジェクトを一括取得できること' do
      users = client.user.get_bulk([username], raise_when_not_found: true)
      expect(users).to be_an(Array)
      expect(users.first.name).to eq(username)
    end
  end

  describe 'ClientPrivateMessageMethods' do
    let(:test_recipient_name) { username } # テスト用に自分宛てに送信
    let(:test_subject) { "Test Subject" }
    let(:test_body) { "This is a test message body." }
    let(:recipient) { client.user.get(test_recipient_name, raise_when_not_found: true) }

    it 'プライベートメッセージを送信できること' do
      expect {
        client.private_message.send_message(recipient, test_subject, test_body)
      }.not_to raise_error
    end

    it '受信箱のメッセージを取得できること' do
      inbox = client.private_message.get_inbox
      expect(inbox).to be_a_kind_of(Wikidotrb::Module::PrivateMessageInbox)
    end

    it '送信箱のメッセージを取得できること' do
      sentbox = client.private_message.get_sentbox
      expect(sentbox).to be_a_kind_of(Wikidotrb::Module::PrivateMessageSentBox)
    end

    it 'メッセージIDからメッセージを取得できること' do
      inbox = client.private_message.get_inbox
      if inbox.any?
        message_id = inbox.first.id
        message = client.private_message.get_message(message_id)
        expect(message.id).to eq(message_id)
      else
        skip "受信箱にメッセージがないため、テストをスキップします。"
      end
    end

    it 'メッセージIDリストからメッセージを一括取得できること (2件)' do
      inbox = client.private_message.get_inbox
      if inbox.any?
        if inbox.size < 2
          skip "受信箱のメッセージが2件未満のため、テストをスキップします。"
        end
        message_ids = inbox.take(2).map(&:id)
        messages = client.private_message.get_messages(message_ids)
        expect(messages.size).to eq(2)
      else
        skip "受信箱にメッセージがないため、テストをスキップします。"
      end
    end

    
  end

  describe 'ClientSiteMethods' do
    it 'サイトのドメインからサイトオブジェクトを取得できること' do
      site = client.site.get(site_domain)
      expect(site.domain).to eq("#{site_domain}.wikidot.com")
    end

    it '取得したサイトのSSL対応状況が正しいこと' do
      site = client.site.get(site_domain)
      expect([true, false]).to include(site.ssl_supported)
    end
  end

  after(:each) do
    # 各テストケース終了後にクライアントをログアウト
    client.finalize if client.is_logged_in
  end
end
