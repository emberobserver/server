# frozen_string_literal: true

module AddonScore
  module Checks
    class GithubContributors < Check
      def name
        :github_contributors
      end

      def max_value
        1
      end

      def weight
        1
      end

      def value
        if addon.valid_github_repo? && addon.github_contributors_count > 1
          1
        else
          0
        end
      end
    end
  end
end
