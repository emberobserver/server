# frozen_string_literal: true

module AddonScore
  module Checks
    class OneDotO < Check
      def name
        :is_1_0
      end

      def explanation
        'Has released a stable version (read: >= 1.0), following semver'
      end

      def max_value
        1
      end

      def weight
        0.2
      end

      def value
        return 0 unless addon.latest_version
        version_parts = addon.latest_version.split('.')
        return 1 if version_parts[0].to_i >= 1
        0
      end
    end
  end
end
