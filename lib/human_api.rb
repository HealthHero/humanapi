require 'active_support/all'
require 'json'
require 'nestful'
require 'human_api/version'
require 'human_api/config'
require 'config/initializers/core_ext'

module HumanApi

  @config = HumanApi::Config.new

  def self.config
    if block_given?
      yield @config
      @config.configure
    else
      @config
    end
  end

  autoload :Human, 'human_api/human'
  autoload :App,   'human_api/app'
end
