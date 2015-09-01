module HumanApi
  class Human < Nestful::Resource

    attr_reader :token

    endpoint 'https://api.humanapi.co'
    path     '/v1/human'

    # The available methods for this api
    AVAILABLE_METHODS = %i{
      profile activities blood_glucose blood_oxygen blood_pressure body_fat genetic_traits heart_rate height locations sleeps weight bmi
    }.freeze

    def initialize(options)
      @token = options[:access_token]
      super
    end

    # Profile =====================================

    def summary
      get '', access_token: token
    end

    def profile(options = {})
      query :profile, options
    end

    # =============================================

    def query(method, options = {})
      unless AVAILABLE_METHODS.include? method.to_sym
        raise ArgumentError, "The method '#{method}' does not exist!"
      end

      # From sym to string
      method = method.to_s

      # The base of the url
      url = "#{method}"

      # If it is a singular word prepare for readings
      if method.is_singular?
        if options[:readings] == true
          url += "/readings"
        end
      else
        if options[:summary] == true
          url += "/summary"
        end
      end

      # You passed a date
      if options[:date].present?
        # Make a request for a specific date
        url += "/daily/#{options[:date]}"
      # If you passed an id
      elsif options[:id].present?
        # Make a request for a single
        url += "/#{options[:id]}"
      end

      params = {access_token: token}

      if options[:fetch_all]
        results        = []
        first_request  = get url, params
        total_size     = first_request.headers['x-total-count'].to_i
        results        = results + JSON.parse(first_request.body)
        next_page_link = first_request.headers['link'].match(/<(https[^>]*)>/)[1]

        while results.count < total_size
          next_page      = Nestful.get next_page_link
          next_page_link = next_page.headers['link'].match(/<(https[^>]*)>/)[1]
          results        = results + JSON.parse(next_page.body)
        end

        results
      else
        params.merge!(limit: options[:limit])   if options[:limit].present?
        params.merge!(offset: options[:offset]) if options[:offset].present?

        result = get url, params
        if options[:return_metadata]
          result
        else
          JSON.parse result.body
        end
      end
    end
  end
end
