# frozen_string_literal: true

module AddonScore
  module Checks
    class HasTests < Check
      def name
        :has_tests
      end

      def max_value
        1
      end

      def weight
        1
      end

      def value
        addon.has_tests == 1 ? 1 : 0
      end
    end
  end
end
