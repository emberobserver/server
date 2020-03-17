# frozen_string_literal: true

class PackageListFetcher
  FETCH_URL = 'http://127.0.0.1:5984/npm/_design/app/_view/latest-version-dates'

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
    response = Request.get(FETCH_URL, userpwd: [ENV['COUCHDB_USERNAME'], ENV['COUCHDB_PASSWORD']].join(':'))

    unless response.success?
      if response.timed_out?
        Bugsnag.notify('Timed out fetching addon list from couchdb')
      else
        Bugsnag.notify('Failure fetching addon list from couchdb')
        Bugsnag.notify("HTTP request failed: #{response.code}")
      end
      return []
    end

    parse_response(response).tap do |parsed_response|
      if parsed_response.blank?
        Rails.logger.warn('No packages returned when fetching addon list from couchdb')
      end
    end
  end

  def self.parse_response(response)
    rows = JSON.parse(response.body)['rows']
    rows.map do |r|
      { name: r['key'], date: r['value'] }
    end
  end
end
