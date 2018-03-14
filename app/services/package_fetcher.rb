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
    base_url = "https://registry.npmjs.org/"
    sanitized_name = addon_name.gsub('/', '%2F')

      response = Request.get("#{base_url}#{sanitized_name}")
      if response.success?
        begin
          response_body = response.body
          contents = JSON.parse(response_body)
          NpmAddonDataUpdater.new(contents).update
        rescue
          Rails.logger.warn("Response not as expected for #{addon_name}")
        end
      elsif response.timed_out?
        Rails.logger.warn("Timed out fetching addon from npm #{addon_name}")
      else
        Rails.logger.warn("Failure fetching addon from npm #{addon_name}")
        Rails.logger.warn("HTTP request failed: #{response.code}")
      end
  end
end
