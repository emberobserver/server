# frozen_string_literal: true

module AddonScore
  module Checks
    class TopDownloaded < Check
      def name
        :top_downloaded
      end

      def max_value
        1
      end

      def weight
        1
      end

      def value
        addon.is_top_downloaded ? 1 : 0
      end
    end
  end
end
