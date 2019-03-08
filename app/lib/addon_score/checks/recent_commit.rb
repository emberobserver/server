# frozen_string_literal: true

module AddonScore
  module Checks
    class RecentCommit < Check
      def name
        :recent_commit
      end

      def explanation
        if value == 1
          'Has more than one commit in the past three months'
        else
          'Does NOT have more than one commit in the past three months or does not have a valid Github repository set in `package.json`'
        end
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
