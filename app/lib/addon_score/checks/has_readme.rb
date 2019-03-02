# frozen_string_literal: true

module AddonScore
  module Checks
    class HasReadme < Check
      def name
        :has_readme
      end

      def max_value
        1
      end

      def weight
        1
      end

      def value
        addon.has_readme == 1 ? 1 : 0
      end
    end
  end
end
