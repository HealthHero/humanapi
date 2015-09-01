module HumanApi
  class Config
    attr_accessor :app_id, :query_key, :client_secret, :human_model, :token_method_name, :hardcore, :raise_access_errors, :handle_access_error

    CHECK_THE_GUIDE = "Read the guide for more information. (https://github.com/Pazienti/humanapi)"

    def initialize
      @hardcore            = false
      @raise_access_errors = false
    end

    def configure
      rewrite_human_model
    end

    def rewrite_human_model
      if human_model.present? && token_method_name.present?
        if human_model.instance_methods.include?(token_method_name)

          human_model.class_eval do
            attr_accessor :human_var

            def human
              @human_var ||= HumanApi::Human.new(access_token: self.send(HumanApi.config.token_method_name.to_sym))
            end
          end
        else
          raise "Could not find '#{token_method_name}' in #{human_model}. #{CHECK_THE_GUIDE}"
        end
      else
        # unless hardcore
        #   raise "You must set a human_model and a token_method_name. #{CHECK_THE_GUIDE}"
        # end
      end
    end
  end
end
