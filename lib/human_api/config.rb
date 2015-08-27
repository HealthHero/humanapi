
# THE MODULE
module HumanApi
  # THE CLASS
  class Config
    attr_accessor :app_id, :query_key, :human_model, :token_method_name, :hardcore

    CHECK_THE_GUIDE = "Read the guide for more information. (https://github.com/Pazienti/humanapi)"

    # Init some vars
    def initialize
      @hardcore = false
    end

    # Init some vars
    def configure
      rewrite_human_model
    end

    # Rewrite the human model
    def rewrite_human_model
      # Check if the human_model to use and the method name are present
      if human_model.present? and token_method_name.present?

        # Check if the method given exists in the given class
        if human_model.instance_methods.include?(token_method_name)

          # Rewrite the class adding a method
          human_model.class_eval do
            attr_accessor :human_var

            # The method in the human_model class instance
            def human
              # Initialize with the access token
              @human_var ||= HumanApi::Human.new(:access_token => self.send(HumanApi.config.token_method_name.to_sym))
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
