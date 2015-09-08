module HumanApi
  class App < Nestful::Resource

    endpoint 'https://api.humanapi.co'
    path     "/v1/apps/#{HumanApi.config.app_id}"
    options  auth_type: :basic, user: HumanApi.config.query_key, password: ''

    # Get the humans of your app:
    def self.humans
      get 'users'
    rescue Nestful::UnauthorizedAccess => e
      if HumanApi.config.handle_access_error
        HumanApi.config.handle_access_error.call e, self
      else
        raise if HumanApi.config.raise_access_errors
        []
      end
    end

    # Create a new human:
    def self.create_human(id)
      response = post 'users', externalId: id

      # If the response is true
      if response.status >= 200 && response.status < 300 # Leave it for now
        JSON.parse response.body
      else
        # Else tell me something went wrong:
        false # Nothing was created
      end
    rescue Nestful::UnauthorizedAccess => e
      if HumanApi.config.handle_access_error
        HumanApi.config.handle_access_error.call e, self
      else
        raise if HumanApi.config.raise_access_errors
        false
      end
    end

    # Delete a new human:
    def self.delete_human(id)
      response = delete "users/#{id}"

      response.status >= 200 && response.status < 300
    rescue Nestful::UnauthorizedAccess => e
      if HumanApi.config.handle_access_error
        HumanApi.config.handle_access_error.call e, self
      else
        raise if HumanApi.config.raise_access_errors
        false
      end
    end
  end
end
