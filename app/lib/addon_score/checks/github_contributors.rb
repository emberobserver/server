# frozen_string_literal: true

module AddonScore
  module Checks
    class GithubContributors < Check
      def name
        :github_contributors
      end

      def explanation
        'Has at least 3 contributors on GitHub'
      end

      def max_value
        1
      end

      def weight
        1
      end

      def value
        return 0 unless addon.valid_github_repo?
        return 1 if addon.github_contributors.count > 5
        return 0.5 if addon.github_contributors.count > 3
        0
      end
    end
  end
end
