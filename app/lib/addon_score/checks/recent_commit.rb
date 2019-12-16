# frozen_string_literal: true

module AddonScore
  module Checks
    class RecentCommit < Check
      def name
        :recent_commit
      end

      def explanation
        'Has a commit in the last 12 months'
      end

      def max_value
        100
      end

      def weight
        1
      end

      def value
        return 0 unless addon.valid_github_repo?
        return 0 unless addon.github_stats
        latest_commit = addon.github_stats.penultimate_commit_date
        return 0 unless latest_commit
        threshold = threshold_for_date(latest_commit)
        return threshold[:value] if threshold
        0
      end

      private

      THRESHOLDS = [
        { date: 3.months.ago, value: 100, text: '3 months' },
        { date: 6.months.ago, value: 80, text: '6 months' },
        { date: 12.months.ago, value: 50, text: 'year' },
      ].freeze

      def threshold_for_date(date)
        THRESHOLDS.find { |t| date >= t[:date] }
      end
    end
  end
end
