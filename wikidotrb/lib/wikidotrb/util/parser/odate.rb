require 'nokogiri'
require 'time'

module Wikidotrb
  module Util
    class ODateParser
      # odate要素を解析し、Timeオブジェクトを返す
      # @param odate_element [Nokogiri::XML::Element] odate要素
      # @return [Time] odate要素が表す日時
      # @raise [ArgumentError] odate要素が有効なunix timeを含んでいない場合
      def self.parse(odate_element)
        odate_classes = odate_element['class'].split

        # "time_"が含まれるクラスを検索
        odate_classes.each do |odate_class|
          if odate_class.include?('time_')
            unix_time = odate_class.sub('time_', '').to_i
            return Time.at(unix_time)
          end
        end

        raise ArgumentError, 'odate element does not contain a valid unix time'
      end
    end
  end
end
