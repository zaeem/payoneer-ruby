#Payoneer Ruby bindings
#API spec at https://github.com/teespring/payoneer-ruby
require 'rest-client'
require 'active_support'
require 'active_support/core_ext'

# Version
require 'payoneer/version'

# Configuration
require 'payoneer/configuration'

# Errors
require 'payoneer/errors/unexpected_response_error'
require 'payoneer/errors/configuration_error'

module Payoneer
  class << self
    attr_accessor :configuration
  end

  def self.configure
    yield(_configuration)
  end

  def self.make_api_request(method_name, params = {})
    _configuration.validate!

    request_params = default_params.merge(mname: method_name).merge(params)

    response = RestClient.post(_configuration.api_url, request_params)

    fail Errors::UnexpectedResponseError.new(response.code, response.body) unless response.code == 200

    hash_response = Hash.from_xml(response.body)
    inner_content = hash_response.values.first
    inner_content
  end

  private

  def self._configuration
    self.configuration ||= Configuration.new
  end

  def self.default_params
    {
      p1: _configuration.partner_username,
      p2: _configuration.partner_api_password,
      p3: _configuration.partner_id,
    }
  end
end
