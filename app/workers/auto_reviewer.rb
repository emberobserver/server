# frozen_string_literal: true

class AutoReviewer
  def self.rereview_addons
    # get addons needing re-review
    addons = Addon.needing_rereview

    # filter list to addons with all 5 points on most recent reviews
    addons = addons.select do |addon|
      review = addon.newest_review
      review.has_tests == 1 &&
        review.has_readme == 1 &&
        review.is_more_than_empty_addon == 1 &&
        review.is_open_source == 1 &&
        review.has_build == 1
    end

    addons.each do |addon|
      # create all-yes review for newest version
      review = addon.newest_review.dup
      review.addon_version = addon.newest_version
      review.save!
    end
  end
end
