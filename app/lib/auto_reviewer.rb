# frozen_string_literal: true

class AutoReviewer
  def self.rereview_addons
    # get addons needing re-review
    addons = Addon.needing_rereview

    # filter list to addons with all 5 points on most recent reviews
    addons = addons.select do |addon|
      review = addon.newest_review
      next if review.nil?
      review.has_tests == 1 &&
        review.has_readme == 1 &&
        review.has_build == 1
    end

    addons.each do |addon|
      # create all-yes review for newest version
      review = addon.newest_review.dup
      review.addon_version = addon.latest_addon_version
      review.save!
      addon.update(latest_review: review)
    end
  end
end
