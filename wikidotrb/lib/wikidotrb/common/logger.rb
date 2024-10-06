# frozen_string_literal: true

require "logger"

module Wikidotrb
  module Common
    # Logger設定
    def self.setup_logger(name = "wikidot", level = Logger::INFO)
      # ロガーの作成
      _logger = Logger.new($stdout)
      _logger.progname = name
      _logger.level = level

      # ログフォーマット
      _logger.formatter = proc do |severity, datetime, progname, msg|
        "#{datetime} [#{progname}/#{severity}] #{msg}\n"
      end

      _logger
    end

    # ロガーの初期化
    Logger = setup_logger
  end
end
