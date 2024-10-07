# frozen_string_literal: true

require "spec_helper"
require "wikidotrb/util/parser/user"
require "nokogiri"

RSpec.describe Wikidotrb::Util::Parser::UserParser do
  let(:client) { instance_double("Client") } # 実際のクライアントオブジェクトを使用

  describe ".parse" do
    context "削除されたユーザー要素が渡された場合" do
      let(:html) do
        <<-HTML
          <span class="printuser deleted" data-id="12345">
            <img class="small" src="http://www.wikidot.com/common--images/avatars/default/a16.png" alt="">
            (account deleted)
          </span>
        HTML
      end
      let(:elem) { Nokogiri::HTML.fragment(html).at_css("span") }

      it "DeletedUserオブジェクトを返すこと" do
        user = described_class.parse(client, elem)
        expect(user).to be_a_kind_of(Wikidotrb::Module::DeletedUser)
        expect(user.id).to eq(12_345)
      end
    end

    context "匿名ユーザー要素が渡された場合" do
      let(:html) do
        <<-HTML
          <span class="printuser anonymous">
            <a href="javascript:;" onclick="WIKIDOT.page.listeners.anonymousUserInfo('192.168.0.1'); return false;">
              Anonymous
              <span class="ip">(192.168.0.x)</span>
            </a>
          </span>
        HTML
      end
      let(:elem) { Nokogiri::HTML.fragment(html).at_css("span") }

      it "AnonymousUserオブジェクトを返すこと" do
        user = described_class.parse(client, elem)
        expect(user).to be_a_kind_of(Wikidotrb::Module::AnonymousUser)
        expect(user.ip).to eq("192.168.0.1")
        expect(user.ip_masked).to eq("192.168.0.x")
      end
    end

    context "匿名ユーザー要素が渡された場合(has avatar)" do
      let(:html) do
        <<-HTML
          <span class="printuser anonymous">
            <a href="javascript:;" onclick="WIKIDOT.page.listeners.anonymousUserInfo('192.168.0.1'); return false;">
              <img class="small" src="http://www.wikidot.com/common--images/avatars/default/a16.png" alt="">
            </a>
            <a href="javascript:;" onclick="WIKIDOT.page.listeners.anonymousUserInfo('192.168.0.1'); return false;">Anonymous#{" "}
              <span class="ip">(192.168.0.x)</span>
            </a>
          </span>
        HTML
      end
      let(:elem) { Nokogiri::HTML.fragment(html).at_css("span") }

      it "AnonymousUserオブジェクトを返すこと" do
        user = described_class.parse(client, elem)
        expect(user).to be_a_kind_of(Wikidotrb::Module::AnonymousUser)
        expect(user.ip).to eq("192.168.0.1")
        expect(user.ip_masked).to eq("192.168.0.x")
      end
    end

    context "ゲストユーザー要素が渡された場合" do
      let(:html) do
        <<-HTML
          <span class="printuser avatarhover">
            <a href="javascript:;">
              <img class="small" src="http://www.gravatar.com/avatar.php?gravatar_id=1&default=http://www.wikidot.com/common--images/avatars/default/a16.png&size=16" alt="">
            </a>
            guest (guest)
          </span>
        HTML
      end
      let(:elem) { Nokogiri::HTML.fragment(html).at_css("span") }

      it "GuestUserオブジェクトを返すこと" do
        user = described_class.parse(client, elem)
        expect(user).to be_a_kind_of(Wikidotrb::Module::GuestUser)
        expect(user.name).to eq("guest")
      end
    end

    context "Wikidotユーザー要素が渡された場合" do
      let(:html) { '<span class="printuser">Wikidot</span>' }
      let(:elem) { Nokogiri::HTML.fragment(html).at_css("span") }

      it "WikidotUserオブジェクトを返すこと" do
        user = described_class.parse(client, elem)
        expect(user).to be_a_kind_of(Wikidotrb::Module::WikidotUser)
        expect(user.name).to eq("Wikidot")
      end
    end

    context "通常のユーザー要素が渡された場合" do
      let(:html) do
        <<-HTML
          <span class="printuser">
            <a href="http://www.wikidot.com/user:info/testuser" onclick="WIKIDOT.page.listeners.userInfo(6789); return false;">testuser</a>
          </span>
        HTML
      end
      let(:elem) { Nokogiri::HTML.fragment(html).at_css("span") }

      it "Userオブジェクトを返すこと" do
        user = described_class.parse(client, elem)
        expect(user).to be_a_kind_of(Wikidotrb::Module::User)
        expect(user.id).to eq(6789)
        expect(user.name).to eq("testuser")
        expect(user.unix_name).to eq("testuser")
        expect(user.avatar_url).to eq("http://www.wikidot.com/avatar.php?userid=6789")
      end
    end

    context "通常のユーザー要素が渡された場合(has avatar)" do
      let(:html) do
        <<-HTML
          <span class="printuser avatarhover">
            <a href="http://www.wikidot.com/user:info/testuser" onclick="WIKIDOT.page.listeners.userInfo(6789); return false;">
              <img class="small" src="http://www.wikidot.com/avatar.php?userid=6789&size=small&timestamp=1" alt="testuser001" style="background-image:url(http://www.wikidot.com/userkarma.php?u=6789)">
            </a>
            <a href="http://www.wikidot.com/user:info/testuser" onclick="WIKIDOT.page.listeners.userInfo(6789); return false;">
              testuser
            </a>
          </span>
        HTML
      end
      let(:elem) { Nokogiri::HTML.fragment(html).at_css("span") }

      it "Userオブジェクトを返すこと" do
        user = described_class.parse(client, elem)
        expect(user).to be_a_kind_of(Wikidotrb::Module::User)
        expect(user.id).to eq(6789)
        expect(user.name).to eq("testuser")
        expect(user.unix_name).to eq("testuser")
        expect(user.avatar_url).to eq("http://www.wikidot.com/avatar.php?userid=6789")
      end
    end

    context "要素がnilの場合" do
      it "nilを返すこと" do
        user = described_class.parse(client, nil)
        expect(user).to be_nil
      end
    end

    context "(user deleted)の場合" do
      let(:html_string) { "(user deleted)" }

      it "DeletedUserオブジェクトを返すこと" do
        user = described_class.parse(client, html_string)
        expect(user).to be_a_kind_of(Wikidotrb::Module::DeletedUser)
      end
    end

    context "要素がNokogiri::XML::Elementではない場合" do
      let(:html_string) { "Just a string, not an element" }

      it "nilを返すこと" do
        user = described_class.parse(client, html_string)
        expect(user).to be_nil
      end
    end
  end
end
