# frozen_string_literal: true

namespace :reviews do
  desc "Create new reviews for addons that need review and got all points on their last review"
  task autoreview: :environment do
    # get addons needing re-review
    addons = Addon.where('name in (?)', Review.select(:addon_name)).joins(:latest_addon_version).where('addon_versions.id NOT IN (?)', Review.select(:addon_version_id))
    puts "#{addons.length} addons need re-review"

    # filter list to addons with all 5 points on most recent reviews
    addons = addons.select do |addon|
      review = addon.newest_review
      puts "checking addon #{addon.name}"
      review.has_tests == 1 &&
      review.has_readme == 1 &&
      review.is_more_than_empty_addon == 1 &&
      review.is_open_source == 1 &&
      review.has_build == 1
    end

    addons.each do |addon|
      # create all-yes review for newest version
      puts "processing addon #{addon.name}"
      review = addon.newest_review.dup
      review.addon_version = addon.newest_version
      review.save!
    end
  end
end
