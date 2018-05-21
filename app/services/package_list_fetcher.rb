# frozen_string_literal: true

class PackageListFetcher
  FETCH_URL = 'http://registry.npmjs.org/-/v1/search?text=keywords:ember-addon'
  PAGE_SIZE = 250

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

  def self.run(opts = {})
    options = { page_size: PAGE_SIZE }.merge(opts)
    total = 0
    expected_count = 0
    fetched_count = 0
    matching_npm_packages = []

    loop do
      request_params = { size: options[:page_size], from: fetched_count }
      response = Request.get(FETCH_URL, params: request_params)
      if response.success?
        parsed_response = parse_response(response.body)

        unless parsed_response && !parsed_response[:packages].empty?
          Rails.logger.warn("No packages returned when fetching addon list from npm #{request_params}")
          break
        end

        matching_npm_packages.push(*parsed_response[:packages])
        total = parsed_response[:total]

        if fetched_count == 0
          expected_count = total
        end

        fetched_count += parsed_response[:packages].length
      elsif response.timed_out?
        Rails.logger.warn("Timed out fetching addon list from npm #{request_params}")
        break
      else
        Rails.logger.warn("Failure fetching addon list from npm #{request_params}")
        Rails.logger.warn("HTTP request failed: #{response.code}")
        break
      end

      break if fetched_count >= expected_count
    end

    if fetched_count < total
      Rails.logger.warn("Failed to fetch the expected number of addons, got #{fetched_count}/#{total}")
    end

    matching_npm_packages
  end

  def self.parse_response(response)
    return unless response
    contents = JSON.parse(response)
    { packages: contents['objects'], total: contents['total'] }
  end
end
