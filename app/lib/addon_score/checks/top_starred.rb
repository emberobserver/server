# frozen_string_literal: true

module AddonScore
  module Checks
    class TopStarred < Check
      def name
        :is_top_starred
      end

      def explanation
        if value == 1
          'Has a GitHub star count in the top 10% of all addons'
        else
          'Does not have a GitHub star count in the top 10% of all addons'
        end
      end

      def max_value
        1
      end

      def weight
        0.5
      end

      def value
        if addon.valid_github_repo? && addon.is_top_starred
          1
        else
          0
        end
      end
    end
  end
end
