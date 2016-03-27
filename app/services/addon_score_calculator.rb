class AddonScoreCalculator
  def self.calculate_score(addon)
    score = nil
    review = addon.newest_review
    if review
      score = 0
      score = score + 1 if review.has_tests == 1
      score = score + 1 if review.has_readme == 1
      score = score + 1 if review.is_more_than_empty_addon == 1
      score = score + 1 if review.is_open_source == 1
      score = score + 1 if review.has_build == 1

      score = score + 1 if addon.recently_released?
      score = score + 1 if addon.recently_committed_to?
      score = score + 1 if addon.is_top_downloaded
      score = score + 1 if addon.is_top_starred
      score = score + 1 if addon.github_contributors.length > 1
    end

    score
  end
end
