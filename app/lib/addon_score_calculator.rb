# frozen_string_literal: true

class AddonScoreCalculator
  def self.calculate_score(addon)
    score = nil
    review = addon.newest_review
    if review
      score = 2
      score += 1 if review.has_tests == 1
      score += 1 if review.has_readme == 1
      score += 1 if review.has_build == 1

      score += 1 if addon.recently_released?
      score += 1 if addon.is_top_downloaded
      unless addon.has_invalid_github_repo?
        score += 1 if addon.github_contributors.length > 1
        score += 1 if addon.recently_committed_to?
        score += 1 if addon.is_top_starred
      end
    end

    score
  end
end
