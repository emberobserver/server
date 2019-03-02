# frozen_string_literal: true

module AddonScore
  module Checks
    class RecentCommit < Check
      def name
        :recent_commit
      end

      def max_value
        1
      end

      def weight
        1
      end

      def value
        if addon.valid_github_repo? && addon.recently_committed_to?
          1
        else
          0
        end
      end
    end
  end
end
