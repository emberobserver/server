# frozen_string_literal: true

module AddonScore
  module Checks
    class TopDownloaded < Check
      def name
        :top_downloaded
      end

      def explanation
        if value == 1
          'Has a npm download count in the top 10% of all addons'
        else
          'Does not have a download count in the top 10% for download count of all addons'
        end
      end

      def max_value
        1
      end

      def weight
        0.5
      end

      def value
        addon.is_top_downloaded ? 1 : 0
      end
    end
  end
end
