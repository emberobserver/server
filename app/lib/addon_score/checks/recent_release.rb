# frozen_string_literal: true

module AddonScore
  module Checks
    class RecentRelease < Check
      def name
        :recent_release
      end

      def explanation
        if value > 0
          since_words = threshold_for_date(addon.latest_addon_version.released)[:text]
          "Published a release to `npm` tagged `latest` within the past #{since_words}"
        else
          'Has not published a release to `npm` tagged `latest` within the past year'
        end
      end

      def max_value
        100
      end

      def weight
        1
      end

      def value
        return 0 unless addon.latest_addon_version
        latest_release = addon.latest_addon_version.released
        threshold = threshold_for_date(latest_release)
        return threshold[:value] if threshold
        0
      end

      private

      THRESHOLDS = [
        { date: 3.months.ago, value: 100, text: '3 months' },
        { date: 6.months.ago, value: 80, text: '6 months' },
        { date: 12.months.ago, value: 50, text: 'year' }
      ].freeze

      def threshold_for_date(date)
        THRESHOLDS.find { |t| date >= t[:date] }
      end
    end
  end
end
