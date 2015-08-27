
# THE MODULE
module HumanApi
  # THE CLASS # TODO: Make it an instance of class HumanApi::App :(
  class App < Nestful::Resource

    # The host of the api
    endpoint 'https://api.humanapi.co'

    # The path of the api
    path "/v1/apps/#{HumanApi.config.app_id}"

    # This should be a private method
    def self.authentication
      Base64.encode64("#{HumanApi.config.query_key}:")
    end

    # Get the humans of your app
    def self.humans
      get("users", {}, {:headers => {"Authorization" => "Basic #{authentication}"}})
    end

    # Create a new human
    def self.create_human(id)
      # Make a call to create the user
      response = post("users", {:externalId => id}, {:headers => {"Authorization" => "Basic #{authentication}"}})

      # If the response is true
      if response.status >= 200 and response.status < 300 # Leave it for now
        JSON.parse response.body
      # Else tell me something went wrong
      else
        false # Nothing was created
      end
    end

  end
end
