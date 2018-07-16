# frozen_string_literal: true

require 'net/http'

namespace :addons do
  task update_all: :environment do
    updating_addons = AddonsUpdater.run
    puts "Updating #{updating_addons.length} addons..."
    updating_addons.group_by { |a| a[:reason] }.each_pair do |reason, addons|
      puts "  #{reason}: #{addons.length}"
    end

    if Rails.env.production?
      Snitcher.snitch(ENV['FETCH_SNITCH_ID'])
    end
  end

  task update_repos: [:environment, 'github:update:all']

  task update_meta: [:environment, 'addons:update:downloads_flag', 'addons:update:stars_flag', 'addons:update:scores', 'addons:update:ranking', 'addons:update:search_indexes', 'addons:update:notify']

  namespace :update do
    desc 'Update download count for addons'
    task download_count: :environment do
      Addon.all.each do |addon|
        addon.last_month_downloads = addon.downloads.where('date > ?', 1.month.ago).sum(:downloads)
        addon.save
      end
    end

    desc "Update 'top 10%' flag for addon downloads"
    task downloads_flag: [:environment, 'addons:update:download_count'] do
      total_addons = Addon.active.count
      Addon.update_all(is_top_downloaded: false)
      Addon.active.order('last_month_downloads desc').each_with_index do |addon, index|
        if (index + 1).to_f / total_addons <= 0.10
          addon.is_top_downloaded = true
          addon.save
        end
      end
    end

    desc 'Update ranking for top 100 addons'
    task ranking: [:environment] do
      Addon.update_all(ranking: nil)
      Addon.top_n(100).each_with_index do |addon, index|
        addon.ranking = index + 1
        addon.save
      end
    end

    desc "Update 'top 10%' flag for Github stars"
    task stars_flag: :environment do
      addons_with_stars = Addon.active.includes(:github_stats).references(:github_stats).where('github_stats.addon_id is not null and stars is not null')
      total_addons_with_stars = addons_with_stars.count
      Addon.update_all(is_top_starred: false)
      addons_with_stars.order('stars desc').each_with_index do |addon, index|
        if (index + 1).to_f / total_addons_with_stars <= 0.10
          addon.is_top_starred = true
          addon.save
        end
      end
    end

    desc 'Update scores for addons'
    task scores: :environment do
      Addon.all.each do |addon|
        AddonScoreUpdater.perform_async(addon.id)
      end
    end

    desc 'Update latest version number for ember-cli'
    task ember_cli_version: :environment do
      result = JSON.load(get_url('http://registry.npmjs.org/ember-cli'))
      version = result['dist-tags']['latest']
      if version
        ember_cli = LatestVersion.find_or_create_by(package: 'ember-cli')
        ember_cli.version = version
        ember_cli.save!
      end
    end

    desc 'Update indexes for full text search'
    task search_indexes: :environment do
      ReadmeView.refresh
    end

    desc "Notify Dead Man's Snitch of completion"
    task notify: :environment do
      if Rails.env.production?
        Snitcher.snitch(ENV['UPDATE_SNITCH_ID'])
      end
    end
  end
end

def get_url(url)
  Net::HTTP.get(URI.parse(url))
end
