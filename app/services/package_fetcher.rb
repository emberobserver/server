# frozen_string_literal: true

class PackageFetcher
  class Request
    def self.get(url)
      request = Typhoeus::Request.new(url)
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

  def self.run(addon_name)
    base_url = 'https://registry.npmjs.org/'
    sanitized_name = addon_name.gsub('/', '%2F')

    response = Request.get("#{base_url}#{sanitized_name}")
    if response.success?
      response_body = response.body
      return JSON.parse(response_body)
    elsif response.timed_out?
      raise RuntimeError, "Timed out fetching addon from npm #{addon_name}"
    else
      raise RuntimeError, "Failure fetching addon from npm #{addon_name}, #{response.code}"
    end
  end
end
