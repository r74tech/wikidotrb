module Wikidotrb
  module Connector
    # APIキーのオブジェクト
    class APIKeys
      # 読み取り専用の属性
      attr_reader :ro_key, :rw_key

      # 初期化
      # @param ro_key [String] Read Only Key
      # @param rw_key [String] Read-Write Key
      def initialize(ro_key:, rw_key:)
        @ro_key = ro_key
        @rw_key = rw_key
        freeze
      end
    end
  end
end