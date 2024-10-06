require 'spec_helper'
require 'wikidotrb/module/user'

RSpec.describe Wikidotrb::Module::AbstractUser do
  let(:client) { instance_double('Client') }
  let(:user_id) { 12345 }
  let(:user_name) { 'username' }
  let(:user_unix_name) { 'username' }
  let(:avatar_url) { 'https://www.wikidot.com/avatar.php?userid=12345' }

  it 'ユーザーオブジェクトを作成できること' do
    user = described_class.new(client: client, id: user_id, name: user_name, unix_name: user_unix_name, avatar_url: avatar_url)
    expect(user.client).to eq(client)
    expect(user.id).to eq(user_id)
    expect(user.name).to eq(user_name)
    expect(user.unix_name).to eq(user_unix_name)
    expect(user.avatar_url).to eq(avatar_url)
  end
end


RSpec.describe Wikidotrb::Module::DeletedUser do
  let(:client) { instance_double('Client') }

  it '削除されたユーザーオブジェクトを作成できること' do
    deleted_user = described_class.new(client: client, id: 12345)
    expect(deleted_user.name).to eq('account deleted')
    expect(deleted_user.unix_name).to eq('account_deleted')
  end
end

RSpec.describe Wikidotrb::Module::AnonymousUser do
  let(:client) { instance_double('Client') }
  let(:masked_ip) { '192.168.0.x' }
  let(:ip_address) { '192.168.0.1' }

  it '匿名ユーザーオブジェクトを作成できること' do
    anonymous_user = described_class.new(client: client, ip: masked_ip)
    expect(anonymous_user.name).to eq('Anonymous')
    expect(anonymous_user.ip).to eq(masked_ip)
  end

  it '完全なIPが取得できる場合はそちらを使用すること' do
    anonymous_user = described_class.new(client: client, ip: ip_address, ip_masked: masked_ip)
    expect(anonymous_user.name).to eq('Anonymous')
    expect(anonymous_user.ip).to eq(ip_address)
    expect(anonymous_user.ip_masked).to eq(masked_ip)
  end
end

RSpec.describe Wikidotrb::Module::GuestUser do
  let(:client) { instance_double('Client') }
  let(:guest_name) { 'guest_user' }
  let(:avatar_url) { 'http://www.gravatar.com/avatar.php?gravatar_id=1&default=http://www.wikidot.com/common--images/avatars/default/a16.png&size=16' }

  it 'ゲストユーザーオブジェクトを作成できること' do
    guest_user = described_class.new(client: client, name: guest_name, avatar_url: avatar_url)
    expect(guest_user.name).to eq(guest_name)
    expect(guest_user.avatar_url).to eq(avatar_url)
  end
end

RSpec.describe Wikidotrb::Module::WikidotUser do
  let(:client) { instance_double('Client') }

  it 'Wikidotシステムユーザーオブジェクトを作成できること' do
    wikidot_user = described_class.new(client: client)
    expect(wikidot_user.name).to eq('Wikidot')
    expect(wikidot_user.unix_name).to eq('wikidot')
  end
end
