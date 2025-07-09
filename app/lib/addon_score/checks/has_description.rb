# frozen_string_literal: true

module AddonScore
  module Checks
    class HasDescription < Check
      def name
        :has_description
      end

      def explanation
        'Has a non-default description'
      end

      def max_value
        1
      end

      def weight
        0.05
      end

      def value
        return 0 if addon.description == "The default blueprint for ember-cli addons."
        return 0 if addon.description == "This README outlines the details of collaborating on this Ember addon."
        1
      end
    end
  end
end
