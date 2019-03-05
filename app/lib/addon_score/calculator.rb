# frozen_string_literal: true

module AddonScore
  class Calculator
    def self.calculate_score(addon)
      score_calc(addon, CHECKS)
    end

    def self.score_calc(addon, check_classes)
      checks = check_classes.map do |check_class|
        check_class.new(addon)
      end

      weights_total = checks.sum(&:weight)

      score_components = checks.map do |check|
        ScoreComponentCalculation.new(check, weights_total)
      end

      weighted_value_total = score_components.sum(&:weighted_value)
      score = ((weighted_value_total.to_d / weights_total) * 10)

      {
        addon_name: addon.name,
        score: score.truncate(5),
        checks: score_components.map(&:details)
      }
    end

    class ScoreComponentCalculation
      attr_accessor :max_value,
        :value,
        :weights_total,
        :weight,
        :name

      def initialize(check, weights_total)
        @name = check.name
        @max_value = check.max_value.to_d
        @weight = check.weight.to_d
        @value = check.value.to_d
        @weights_total = weights_total.to_d
      end

      def weighted_value
        normalized_value * weight
      end

      def details
        {
          name: name,
          weighted_value: weighted_value.truncate(5),
          weight: weight.truncate(5),
          max_contribution: max_contribution.truncate(5),
          contribution: contribution.truncate(5)
        }
      end

      private

      def max_contribution
        weight / @weights_total
      end

      def contribution
        max_contribution * (weighted_value / weight)
      end

      def normalized_value
        value / max_value
      end
    end

    CHECKS = [
      Checks::HasTests,
      Checks::HasReadme,
      Checks::HasBuild,
      Checks::RecentRelease,
      Checks::RecentCommit,
      Checks::TopDownloaded,
      Checks::TopStarred,
      Checks::GithubContributors
    ].freeze
  end
end