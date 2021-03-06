# frozen_string_literal: true

module AddonScore
  module Checks
    class GithubContributors < Check
      def name
        :github_contributors
      end

      def explanation
        if value == 1
          'Has more than one contributor on GitHub'
        else
          'Does NOT have more than one contributor on GitHub or does not have a valid Github repository set in `package.json`'
        end
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
