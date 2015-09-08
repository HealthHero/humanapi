module HumanApi
  class Human < Nestful::Resource

    attr_accessor :params, :success, :results, :options, :total_size, :next_page_link
    attr_reader :token

    endpoint 'https://api.humanapi.co'
    path     '/v1/human'

    # The available methods for this api
    AVAILABLE_METHODS = %i{
      profile activities blood_glucose blood_oxygen blood_pressure body_fat genetic_traits
      heart_rate height locations sleeps weight bmi sources
    }.freeze

    def initialize(initial_options)
      @token   = initial_options[:access_token]
      @success = true
      @results = []
      super
    end

    # Profile =====================================

    def summary
      get '', access_token: token
    rescue Nestful::UnauthorizedAccess => e
      if HumanApi.config.handle_access_error
        HumanApi.config.handle_access_error.call e
      else
        raise if HumanApi.config.raise_access_errors
        false
      end
    end

    def profile(options = {})
      query :profile, options
    end

    # =============================================

    def query(method, options = {})
      options.symbolize_keys!
      @options = options

      unless AVAILABLE_METHODS.include? method.to_sym
        raise ArgumentError, "The method '#{method}' does not exist!"
      end

      method = method.to_s
      url    = "#{method}"

      if method.is_singular?
        url += "/readings" if options[:readings] == true
      else
        url += "/summary"   if options[:summary]   == true
        url += "/summaries" if options[:summaries] == true
      end

      if options[:date].present?
        url += "/daily/#{options[:date]}"
      elsif options[:id].present?
        url += "/#{options[:id]}"
      end

      @params = {access_token: token}
      @params.merge!(start_date: options[:start_date]) if options[:start_date].present?
      @params.merge!(end_date:   options[:end_date])   if options[:end_date].present?

      if options[:fetch_all]
        fetch_page url
        while results.count < total_size
          fetch_page
        end

        options[:handle_data] ? @success : results
      else
        @params.merge!(limit: options[:limit])   if options[:limit].present?
        @params.merge!(offset: options[:offset]) if options[:offset].present?
        result = fetch_page url
        options[:return_metadata] ? result : JSON.parse(result.body)
      end
    end

  private

    def fetch_page(url=nil)
      if url
        page        = get url, params
        @total_size = page.headers['x-total-count'].to_i
      else
        page = Nestful.get next_page_link
      end

      @next_page_link = page.headers['link'].match(/<(https[^>]*)>/)[1] if page.headers['link']

      if options[:handle_data]
        JSON.parse(page.body).each do |data|
          @success = false unless options[:handle_data].call data
          @results << '*'
        end
      else
        @results = @results + JSON.parse(page.body) if options[:fetch_all]
        page
      end
    rescue Nestful::UnauthorizedAccess => e
      if HumanApi.config.handle_access_error
        HumanApi.config.handle_access_error.call e
      else
        raise if HumanApi.config.raise_access_errors
        false
      end
    end
  end
end
