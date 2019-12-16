# frozen_string_literal: true

module AddonScore
  module Checks
    class NpmMaintainers < Check
      def name
        :npm_maintainers
      end

      def explanation
        'Has more than 1 maintainer on npm'
      end

      def max_value
        1
      end

      def weight
        1
      end

      def value
        if addon.maintainers.count > 1
          1
        else
          0
        end
      end
    end
  end
end
