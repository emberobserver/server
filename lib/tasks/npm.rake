require 'net/http'

namespace :npm do
  task fetch: :environment do
    sh 'node ./npm-fetch/fetch-all.js'
  end

  task fetch_addon_info: [ 'npm:update:all' ] do
    if Rails.env.production?
      Snitcher.snitch(ENV['FETCH_SNITCH_ID'])
    end
  end

  task :update, [ :name ] => :environment do |_, args|
    name = args[:name]

    metadata = JSON.parse(`node ./npm-fetch/fetch.js #{name}`)
    AddonDataUpdater.new(metadata).update
  end

  namespace :update do
    task all: [ :environment, 'npm:fetch' ] do
      begin
        addons = ActiveSupport::JSON.decode(File.read('/tmp/addons.json'))
      rescue ActiveSupport::JSON.parse_error
        raise "Invalid JSON in addons.json file"
      end

      addons.each do |metadata|
        AddonDataUpdater.new(metadata).update
      end
    end
  end

  task fetch_downloads: :environment do
    addon_names = Addon.pluck(:name)
    File.open('/tmp/addon-names.json', 'w') do |file|
      file << addon_names.to_json
    end
   sh 'node ./npm-fetch/historical-downloads.js'
  end

  task import_downloads: [ :environment, 'npm:fetch_downloads' ] do
    begin
      data = ActiveSupport::JSON.decode(File.read("/tmp/addon-downloads.json"))
    rescue ActiveSupport::JSON.parse_error
      raise "Invalid JSON in addon-downloads.json"
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
