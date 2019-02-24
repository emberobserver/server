# frozen_string_literal: true

class EmberVersionFetcher
  VERSIONS_ENDPOINT = 'https://api.github.com/repos/emberjs/ember.js/releases?per_page=100'

  class Request
    def self.get(url, options)
      request = Typhoeus::Request.new(url, options)
      request.run
      Response.new(request.response)
    end
  end

  class Response
    def initialize(resp)
      @resp = resp
    end

    def success?
      @resp.success?
    end

    def timed_out?
      @resp.timed_out?
    end

    def code
      @resp.code
    end

    def body
      @resp.body
    end
  end

  def self.run
    response = Request.get(VERSIONS_ENDPOINT, {})
    ember_versions = []
    if response.success?
      ember_versions = JSON.parse(response.body)
    elsif response.timed_out?
      Bugsnag.notify("Timed out fetching Ember version list from Github")
    else
      Bugsnag.notify("Failure fetching Ember version list from Github")
      Bugsnag.notify("HTTP request failed: #{response.code}")
    end

    ember_versions
  end
end
