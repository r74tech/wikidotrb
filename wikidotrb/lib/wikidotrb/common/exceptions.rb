# frozen_string_literal: true

module Wikidotrb
  module Common
    module Exceptions
      # ---
      # 基底クラス
      # ---

      class WikidotException < StandardError
        # 独自例外の基底クラス
      end

      # ---
      # ワイルドカード
      # ---

      class UnexpectedException < WikidotException
        # 予期せぬ例外が発生したときの例外
      end

      # ---
      # セッション関連
      # ---

      class SessionCreateException < WikidotException
        # セッションの作成に失敗したときの例外
      end

      class LoginRequiredException < WikidotException
        # ログインが必要なメソッドのときの例外
      end

      # ---
      # AMC関連
      # ---

      class AjaxModuleConnectorException < WikidotException
        # ajax-module-connector.phpへのリクエストに失敗したときの例外
      end

      class AMCHttpStatusCodeException < AjaxModuleConnectorException
        # AMCから返却されたHTTPステータスが200以外だったときの例外
        attr_reader :status_code

        def initialize(message, status_code)
          super(message)
          @status_code = status_code
        end
      end

      class WikidotStatusCodeException < AjaxModuleConnectorException
        # AMCから返却されたデータ内のステータスがokではなかったときの例外
        # HTTPステータスが200以外の場合はAMCHttpStatusCodeExceptionを投げる
        attr_reader :status_code

        def initialize(message, status_code)
          super(message)
          @status_code = status_code
        end
      end

      class ResponseDataException < AjaxModuleConnectorException
        # AMCから返却されたデータが不正だったときの例外
      end

      # ---
      # ターゲットエラー関連
      # ---

      class NotFoundException < WikidotException
        # サイトやページ・ユーザが見つからなかったときの例外
      end

      class TargetExistsException < WikidotException
        # 対象が既に存在しているときの例外
      end

      class TargetErrorException < WikidotException
        # メソッドの対象としたオブジェクトに操作が適用できないときの例外
      end

      class ForbiddenException < WikidotException
        # 権限がないときの例外
      end
    end
  end
end
