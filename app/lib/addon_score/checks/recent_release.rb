# frozen_string_literal: true

module AddonScore
  module Checks
    class RecentRelease < Check
      include ActionView::Helpers::DateHelper

      def name
        :recent_release
      end

      def explanation
        if value > 0
          since_words = time_ago_in_words(addon.latest_addon_version.released)
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
        return 100 if latest_release >= 3.months.ago
        return 80 if latest_release >= 6.months.ago
        return 50 if latest_release >= 12.months.ago
        0
      end
    end
  end
end
