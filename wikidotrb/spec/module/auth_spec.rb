# frozen_string_literal: true

require "spec_helper"
require "wikidotrb/module/auth"
require "wikidotrb/module/client"

RSpec.describe Wikidotrb::Module::HTTPAuthentication do
  let(:username) { RSpec.configuration.test_config["username"] }
  let(:password) { RSpec.configuration.test_config["password"] }

  let(:client) { instance_double("Wikidotrb::Module::Client") }
  let(:amc_client) { instance_double("AMCClient") }
  let(:header) { instance_double("Header") }

  before do
    allow(client).to receive(:amc_client).and_return(amc_client)
    allow(amc_client).to receive(:header).and_return(header)
    allow(header).to receive(:get_header).and_return({ "User-Agent" => "RSpec Test" })
  end

  describe ".login" do
    let(:response) do
      instance_double("HTTPX::Response", status: 200, body: "",
                                         headers: { "set-cookie" => "WIKIDOT_SESSION_ID=123456" })
    end

    context "正しい認証情報が渡された場合" do
      before do
        allow(HTTPX).to receive(:post).and_return(response)
        allow(header).to receive(:set_cookie)
      end

      it "セッションクッキーが設定されること" do
        expect { described_class.login(client, username, password) }.not_to raise_error
        expect(header).to have_received(:set_cookie).with("WIKIDOT_SESSION_ID", "123456")
      end
    end

    context "HTTPステータスコードが200以外の場合" do
      let(:response) { instance_double("HTTPX::Response", status: 401, body: "") }

      before do
        allow(HTTPX).to receive(:post).and_return(response)
      end

      it "SessionCreateExceptionが発生すること" do
        expect do
          described_class.login(client, username, password)
        end.to raise_error(Wikidotrb::Common::Exceptions::SessionCreateException, /HTTP status code: 401/)
      end
    end

    context "無効なユーザー名またはパスワードが渡された場合" do
      let(:response) { instance_double("HTTPX::Response", status: 200, body: "The login and password do not match") }

      before do
        allow(HTTPX).to receive(:post).and_return(response)
      end

      it "SessionCreateExceptionが発生すること" do
        expect do
          described_class.login(client, username, password)
        end.to raise_error(Wikidotrb::Common::Exceptions::SessionCreateException, /invalid username or password/)
      end
    end

    context "クッキーが含まれない場合" do
      let(:response) { instance_double("HTTPX::Response", status: 200, headers: { "set-cookie" => nil }, body: "") }

      before do
        allow(HTTPX).to receive(:post).and_return(response)
      end

      it "SessionCreateExceptionが発生すること" do
        expect do
          described_class.login(client, username, password)
        end.to raise_error(Wikidotrb::Common::Exceptions::SessionCreateException, /invalid cookies/)
      end
    end
  end

  describe ".logout" do
    before do
      allow(amc_client).to receive(:request)
      allow(header).to receive(:delete_cookie)
    end

    it "ログアウトしてセッションが削除されること" do
      expect { described_class.logout(client) }.not_to raise_error
      expect(amc_client).to have_received(:request).with([{ "action" => "Login2Action", "event" => "logout",
                                                            "moduleName" => "Empty" }])
      expect(header).to have_received(:delete_cookie).with("WIKIDOT_SESSION_ID")
    end
  end

  describe "実際のサイトへのログインとログアウト" do
    let(:real_client) { Wikidotrb::Module::Client.new(username: username, password: password) }

    it "実際のWikidotサイトにログインし、セッションクッキーが取得できること" do
      expect { described_class.login(real_client, username, password) }.not_to raise_error
      expect(real_client.amc_client.header.get_cookie("WIKIDOT_SESSION_ID")).not_to be_nil
    end

    it "実際のWikidotサイトからログアウトできること" do
      described_class.login(real_client, username, password)
      expect { described_class.logout(real_client) }.not_to raise_error
      expect(real_client.amc_client.header.get_cookie("WIKIDOT_SESSION_ID")).to be_nil
    end
  end

  describe ".logout" do
    before do
      allow(amc_client).to receive(:request)
      allow(header).to receive(:delete_cookie)
    end

    it "ログアウトしてセッションが削除されること" do
      expect { described_class.logout(client) }.not_to raise_error
      expect(amc_client).to have_received(:request).with([{ "action" => "Login2Action", "event" => "logout",
                                                            "moduleName" => "Empty" }])
      expect(header).to have_received(:delete_cookie).with("WIKIDOT_SESSION_ID")
    end
  end
end
