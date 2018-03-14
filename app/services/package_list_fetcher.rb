class PackageListFetcher
  FETCH_URL = "http://registry.npmjs.org/-/v1/search?text=keywords:ember-addon"
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

        unless parsed_response && parsed_response[:packages].length > 0
          Rails.logger.warn("No packages returned when fetching addon list from npm #{request_params}")
          break
        end

        matching_npm_packages.push(*parsed_response[:packages])
        total = parsed_response[:total]

        if fetched_count == 0
          expected_count += total
        end

        fetched_count = fetched_count + parsed_response[:packages].length
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

  #
  #   addons_needing_updating = []
  #   new_addons = []
  #   matching_npm_packages.each do |a|
  #     addon_data = a["package"]
  #     addon = Addon.find_by(name: addon_data["name"])
  #
  #     if !addon
  #       new_addons << addon_data["name"]
  #       next
  #     end
  #
  #     if DateTime.parse(addon_data["date"]) > addon.latest_version_date
  #       addons_needing_updating << addon_data["name"]
  #     end
  #   end
  #
  #
  #   self.update_addons(addons_needing_updating.push(*new_addons))
  #   pp addons_needing_updating: addons_needing_updating.length
  #   pp new_addons: new_addons.length
  #   nil
  # end
  #
  # def self.update_addons(addon_names)
  #   addon_names.each do |name|
  #     base_url = "https://registry.npmjs.org/"
  #     sanitized_name = name.gsub('/', '%2F')
  #     request = Typhoeus::Request.new("#{base_url}#{sanitized_name}")
  #     request.on_complete do |response|
  #       if response.success?
  #         begin
  #           response_body = response.body
  #           contents = JSON.parse(response_body)
  #           NpmAddonDataUpdater.new(contents).update
  #         rescue
  #           pp failed: name
  #         end
  #       elsif response.timed_out?
  #         # aw hell no
  #         #log("got a time out")
  #       elsif response.code == 0
  #         # Could not get an http response, something's wrong.
  #         #log(response.return_message)
  #       else
  #         # Received a non-successful http response.
  #         #log("HTTP request failed: " + response.code.to_s)
  #       end
  #     end
  #
  #     request.run
  #   end
  end

  def self.parse_response(response)
    if response
      contents = JSON.parse(response)
      { packages: contents["objects"], total: contents["total"] }
    end
  end
end


# returns
#
# "package"=>
#   {"name"=>"ember-cli-htmlbars",
#    "scope"=>"unscoped",
#    "version"=>"2.0.3",
#    "description"=>"A library for adding htmlbars to ember CLI",
#    "keywords"=>["ember-cli", "ember-addon"],
#    "date"=>"2017-07-29T22:20:43.518Z",
#    "links"=>
#      {"npm"=>"https://www.npmjs.com/package/ember-cli-htmlbars",
#       "homepage"=>"https://github.com/ember-cli/ember-cli-htmlbars",
#       "repository"=>"https://github.com/ember-cli/ember-cli-htmlbars",
#       "bugs"=>"https://github.com/ember-cli/ember-cli-htmlbars/issues"},
#    "author"=>{"name"=>"Jonathan Jackson & Chase McCarthy"},
#    "publisher"=>{"username"=>"rwjblue", "email"=>"me@rwjblue.com"},
#    "maintainers"=>
#      [{"username"=>"ember-cli", "email"=>"stefan.penner+ember-cli@gmail.com"},
#       {"username"=>"rondale-sc", "email"=>"jonathan.jackson1@me.com"},
#       {"username"=>"rwjblue", "email"=>"me@rwjblue.com"},
#       {"username"=>"stefanpenner", "email"=>"stefan.penner@gmail.com"}]},
#   "score"=>
#   {"final"=>0.8002942748010851,
#    "detail"=>
#      {"quality"=>0.9531758371062433,
#       "popularity"=>0.4696994768686256,
#       "maintenance"=>0.9998477336148377}},
#   "searchScore"=>0.04297416}
