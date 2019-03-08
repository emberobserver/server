# frozen_string_literal: true

module AddonScore
  module Checks
    class HasBuild < Check
      def name
        :has_build
      end

      def explanation
        if value == 1
          'Awarded manually for having a CI build, only applicable if there are meaningful tests'
        else
          'Does not have CI build and/or does not have meaningful tests'
        end
      end

      def max_value
        1
      end

      def weight
        1
      end

      def value
        addon.has_build == 1 ? 1 : 0
      end
    end
  end
end
