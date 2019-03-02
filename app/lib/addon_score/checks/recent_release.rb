# frozen_string_literal: true

module AddonScore
  module Checks
    class RecentRelease < Check
      def name
        :recent_release
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
