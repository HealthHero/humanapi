module HumanApi
  class User < Nestful::Resource

    endpoint 'https://user.humanapi.co'
    path     '/v1/connect'
    options  auth_type: :basic, user: HumanApi.config.query_key, password: ''

    # Get a public token:
    def self.get_public_token(human_id)
      response = post 'publictokens', humanId: human_id, clientId: HumanApi.config.app_id, clientSecret: HumanApi.config.client_secret
      JSON.parse(response.body)['publicToken']
    rescue Nestful::UnauthorizedAccess => e
      if HumanApi.config.handle_access_error
        HumanApi.config.handle_access_error.call e
      else
        raise if HumanApi.config.raise_access_errors
        nil
      end
    end
  end
end
