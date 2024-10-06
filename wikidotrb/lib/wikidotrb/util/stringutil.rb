# frozen_string_literal: true

require_relative "table/char_table"

module Wikidotrb
  module Util
    class StringUtil
      # Unix形式に文字列を変換する
      # @param target_str [String] 変換対象の文字列
      # @return [String] 変換された文字列
      def self.to_unix(target_str)
        # MEMO: legacy wikidotの実装に合わせている

        # 特殊文字の変換を行う
        special_char_map = Wikidotrb::Table::CharTable::SPECIAL_CHAR_MAP
        target_str = target_str.chars.map { |char| special_char_map[char] || char }.join

        # lowercaseへの変換
        target_str = target_str.downcase

        # ASCII以外の文字を削除し、特殊なケースを正規表現で置き換え
        target_str = target_str.gsub(/[^a-z0-9\-:_]/, "-")
                               .gsub(/^_/, ":_")
                               .gsub(/(?<!:)_/, "-")
                               .gsub(/^-*/, "")
                               .gsub(/-*$/, "")
                               .gsub(/-{2,}/, "-")
                               .gsub(/:{2,}/, ":")
                               .gsub(":-", ":")
                               .gsub("-:", ":")
                               .gsub("_-", "_")
                               .gsub("-_", "_")

        # 先頭と末尾の':'を削除
        target_str.gsub(/^:/, "").gsub(/:$/, "")
      end
    end
  end
end
