module Wikidotrb
  module Common
    module Decorators
      def login_required(*methods)
        methods.each do |method|
          if singleton_methods.include?(method)
            # クラスメソッドにデコレータを適用
            singleton_class.class_eval do
              alias_method "#{method}_without_login_check", method

              define_method(method) do |*args, **kwargs|
                client = nil

                # インスタンス変数として存在するかを最初にチェック
                client ||= self.client if respond_to?(:client)

                # キーワード引数からclientを探す
                client = kwargs[:client] if kwargs.key?(:client)

                # 引数からClientインスタンスを探す
                unless client
                  args.each do |arg|
                    if arg.is_a?(Wikidotrb::Module::Client)
                      client = arg
                      break
                    end
                  end
                end

                # clientが見つからない場合はエラーを発生させる
                raise ArgumentError, "Client is not found" if client.nil?

                # clientのログインチェック
                client.login_check

                # 元のメソッドの呼び出し
                send("#{method}_without_login_check", *args, **kwargs)
              end
            end
          elsif instance_methods.include?(method)
            # インスタンスメソッドにデコレータを適用
            alias_method "#{method}_without_login_check", method

            define_method(method) do |*args, **kwargs|
              client = nil

              # インスタンス変数として存在するかを最初にチェック
              client ||= self.client if respond_to?(:client)

              # キーワード引数からclientを探す
              client = kwargs[:client] if kwargs.key?(:client)

              # 引数からClientインスタンスを探す
              unless client
                args.each do |arg|
                  if arg.is_a?(Wikidotrb::Module::Client)
                    client = arg
                    break
                  end
                end
              end

              # clientが見つからない場合はエラーを発生させる
              raise ArgumentError, "Client is not found" if client.nil?

              # clientのログインチェック
              client.login_check

              # 元のメソッドの呼び出し
              send("#{method}_without_login_check", *args, **kwargs)
            end
          else
            raise NameError, "Undefined method `#{method}` for class `#{self}`"
          end
        end
      end
    end
  end
end
