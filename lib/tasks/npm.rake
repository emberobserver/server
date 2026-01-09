# frozen_string_literal: true

require 'net/http'

namespace :npm do
  task fetch_downloads: :environment do
    addon_names = Addon.not_hidden.pluck(:name)
    File.open('/tmp/addon-names.json', 'w') do |file|
      file << addon_names.to_json
    end
    sh 'node ./npm-fetch/historical-downloads.js'
  end

  task import_downloads: [:environment, 'npm:fetch_downloads'] do
    begin
      data = ActiveSupport::JSON.decode(File.read('/tmp/addon-downloads.json'))
    rescue ActiveSupport::JSON.parse_error
      raise 'Invalid JSON in addon-downloads.json'
    end

    data.each do |download_data|
      next unless download_data.include?('package')
      addon = Addon.where(name: download_data['package']).first
      next unless addon
      download_data['downloads'].each do |downloads|
        addon_downloads = addon.downloads.find_or_create_by(date: downloads['day'])
        addon_downloads.downloads = downloads['downloads']
        addon_downloads.save
      end
    end
  end
end

def get_url(url)
  Net::HTTP.get(URI.parse(url))
end
