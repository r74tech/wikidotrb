# frozen_string_literal: true

require 'rspec'
require 'yaml'
require_relative '../lib/wikidotrb'

# テスト用の設定情報を読み込む
CONFIG = YAML.load_file(File.join(__dir__, '../config.yml'))['test']

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  # テスト用の設定情報をRSpecの設定に追加
  config.add_setting :test_config, default: CONFIG

  config.before(:suite) do
    puts "Starting RSpec suite with test user: #{CONFIG['username']}"
  end
end
