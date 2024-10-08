# frozen_string_literal: true

require "nokogiri"
require "time"

module Wikidotrb
  module Util
    module Parser
      class ODateParser
        # odate要素を解析し、Timeオブジェクトを返す
        # @param odate_element [Nokogiri::XML::Element] odate要素
        # @return [Time] odate要素が表す日時
        # @raise [ArgumentError] odate要素が有効なunix timeを含んでいない場合
        def self.parse(odate_element)
          # odate_elementがNokogiri::XML::Elementでない場合はその内容をパースする
          odate_element = Nokogiri::HTML(odate_element.to_s).at_css(".odate") unless odate_element.is_a?(Nokogiri::XML::Element)

          # 要素がnilの場合やclass属性がない場合はエラー
          raise ArgumentError, "odate element does not contain a valid unix time" if odate_element.nil? || odate_element["class"].nil?

          # クラス属性を取得して処理
          odate_classes = odate_element["class"].split

          # "time_"が含まれるクラスを検索
          odate_classes.each do |odate_class|
            # "time_"が含まれるクラスを検索
            next unless odate_class.start_with?("time_")

            unix_time_str = odate_class.sub("time_", "")
            unix_time = unix_time_str.to_i

            # unix timeが有効な範囲内か確認
            # Wikidotは-8640000000000から8640000000000までの範囲をサポート
            min_unix_time = -8_640_000_000_000
            max_unix_time = 8_640_000_000_000
            raise Wikidotrb::Common::Exceptions::UnexpectedException, "Invalid unix time" if unix_time < min_unix_time || unix_time > max_unix_time

            return Time.at(unix_time)
          end

          # "time_"を含むクラスが見つからなかった場合はエラーを発生させる
          raise ArgumentError, "odate element does not contain a valid unix time"
        end
      end
    end
  end
end
