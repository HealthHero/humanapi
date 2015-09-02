require 'health_hero-human_api'
require 'webmock'
require 'vcr'
require 'pry'
require 'dotenv'
# Dotenv.load

HUMAN_API_APP_ID        = ENV['HUMAN_API_APP_ID']        || 'APP_ID'
HUMAN_API_CLIENT_ID     = ENV['HUMAN_API_CLIENT_ID']     || 'CLIENT_ID'
HUMAN_API_CLIENT_SECRET = ENV['HUMAN_API_CLIENT_SECRET'] || 'CLIENT_SECRET'

HumanApi.config do |c|
  c.app_id        = HUMAN_API_CLIENT_ID
  c.client_secret = HUMAN_API_CLIENT_SECRET
  c.query_key     = HUMAN_API_APP_ID
end

VCR.configure do |config|
  config.allow_http_connections_when_no_cassette = true
  config.cassette_library_dir = "spec/cassettes"
  config.hook_into :webmock
end

RSpec.configure do |config|
  config.mock_framework = :rspec
  config.filter_run focus: true
  config.run_all_when_everything_filtered = true
  config.color = true
end
