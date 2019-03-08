# frozen_string_literal: true

module AddonScore
  module Checks
    class RecentRelease < Check
      def name
        :recent_release
      end

      def explanation
        if value == 1
          'Has published a release on `npm` within the past three months'
        else
          'Has not published a release to `npm` within the past three months'
        end
      end

      def max_value
        1
      end

      def weight
        1
      end

      def value
        addon.recently_released? ? 1 : 0
      end
    end
  end
end
