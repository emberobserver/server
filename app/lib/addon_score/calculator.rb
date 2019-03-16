# frozen_string_literal: true

module AddonScore
  class Calculator
    # The following needs to be bumped any time a check is added, removed,
    # or if a check is changed in anyway. This allows us to see the effect
    # of the change in the scores
    MODEL_VERSION = 1

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
        model_version: MODEL_VERSION,
        checks: score_components.map(&:details)
      }
    end

    class ScoreComponentCalculation
      def initialize(check, weights_total)
        @name = check.name
        @explanation = check.explanation
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
          explanation: explanation,
          weighted_value: weighted_value.truncate(5),
          weight: weight.truncate(5),
          max_contribution: max_contribution.truncate(5),
          contribution: contribution.truncate(5)
        }
      end

      private

      attr_reader :max_value,
        :value,
        :weights_total,
        :weight,
        :name,
        :explanation

      def max_contribution
        weight / weights_total
      end

      def contribution
        weighted_value / weights_total
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
