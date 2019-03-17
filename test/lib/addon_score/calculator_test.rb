# frozen_string_literal: true

require 'test_helper'

class CalculatorTest < ActiveSupport::TestCase
  test 'self.calculate_score full score smoke test' do
    # TODO: Create better factories
    stats = build(:github_stats, penultimate_commit_date: 2.months.ago)
    addon = create(:addon, :with_github_users, github_stats: stats, is_top_downloaded: true, is_top_starred: true)
    addon_version = create(:addon_version, addon: addon, released: 2.months.ago)
    review = create(:review, addon_version: addon_version, has_tests: 1, has_readme: 1, has_build: 1)
    addon.latest_review = review
    addon.latest_addon_version = addon_version
    addon.save

    score_info = AddonScore::Calculator.calculate_score(addon)

    assert_equal(2, AddonScore::Calculator::MODEL_VERSION, 'Model version')
    assert_equal(8, score_info[:checks].length, 'Total # of current checks - if you update this, update the MODEL_VERSION')
    assert_equal(10.0, score_info[:score], 'Perfect score')
  end

  test 'self.calculate_score zero score smoke test' do
    stats = build(:github_stats, penultimate_commit_date: 10.months.ago)
    addon = create(:addon, github_stats: stats, is_top_downloaded: false, is_top_starred: false)
    addon_version = create(:addon_version, addon: addon, released: 13.months.ago)
    review = create(:review, addon_version: addon_version, has_tests: 0, has_readme: 0, has_build: 0)
    addon.latest_review = review
    addon.latest_addon_version = addon_version
    addon.save

    score_info = AddonScore::Calculator.calculate_score(addon)

    assert_equal(0.0, score_info[:score], 'Zero score')
  end

  test 'self.score_calc with one passing check' do
    addon = create(:addon, name: 'ember-try', id: 1, latest_version_date: 1.day.ago.iso8601)

    checks = [
      create_check(
        name: :foo,
        weight: 1,
        max_value: 1,
        value: 1,
        explanation: 'foo'
      )
    ]

    score_calc = AddonScore::Calculator.score_calc(addon, checks)
    assert_equal(10.0, score_calc[:score], 'Perfect score')

    inputs = score_calc[:checks]
    assert_equal({
      name: :foo,
      weight: 1,
      weighted_value: 1.0,
      contribution: 1.0,
      max_contribution: 1.0,
      explanation: 'foo'
    }, inputs[0])
  end

  test 'self.score_calc with one failing check' do
    addon = create(:addon, name: 'ember-try', id: 1, latest_version_date: 1.day.ago.iso8601)
    checks = [
      create_check(
        name: :foo,
        weight: 1,
        max_value: 1,
        value: 0,
        explanation: 'foo'
      )
    ]

    score_calc = AddonScore::Calculator.score_calc(addon, checks)
    assert_equal(0.0, score_calc[:score], '0 score')

    inputs = score_calc[:checks]
    assert_equal({
      name: :foo,
      weight: 1,
      weighted_value: 0.0,
      contribution: 0.0,
      max_contribution: 1.0,
      explanation: 'foo'
    }, inputs[0])
  end

  test 'self.score_calc with one partial check' do
    addon = create(:addon, name: 'ember-try', id: 1, latest_version_date: 1.day.ago.iso8601)
    checks = [
      create_check(
        name: :foo,
        weight: 1,
        max_value: 5,
        value: 2,
        explanation: 'foo'
      )
    ]
    score_calc = AddonScore::Calculator.score_calc(addon, checks)
    assert_equal(4.0, score_calc[:score], 'Middle score')

    inputs = score_calc[:checks]
    assert_equal({
      name: :foo,
      weight: 1,
      weighted_value: 0.4,
      contribution: 0.4,
      max_contribution: 1.0,
      explanation: 'foo'
    }, inputs[0])
  end

  test 'self.score_calc with weighted checks' do
    addon = create(:addon, name: 'ember-try', id: 1, latest_version_date: 1.day.ago.iso8601)
    checks = [
      create_check(
        name: :foo,
        weight: 1,
        max_value: 5,
        value: 2,
        explanation: 'foo'
      ),
      create_check(
        name: :bar,
        weight: 0.8,
        max_value: 1,
        value: 1,
        explanation: 'bar'
      )
    ]

    score_calc = AddonScore::Calculator.score_calc(addon, checks)
    assert_equal(BigDecimal('6.66666'), score_calc[:score], 'Middle score')

    inputs = score_calc[:checks]
    assert_equal({
      name: :foo,
      weight: BigDecimal('1'),
      weighted_value: BigDecimal('0.4'),
      contribution: BigDecimal('0.22222'),
      max_contribution: BigDecimal('0.55555'),
      explanation: 'foo'
    }, inputs[0])
  end

  private

  def create_check(props)
    Class.new(AddonScore::Check) do
      define_method(:name) do
        props[:name]
      end

      define_method(:explanation) do
        props[:explanation]
      end

      define_method(:weight) do
        props[:weight]
      end

      define_method(:max_value) do
        props[:max_value]
      end

      define_method(:value) do
        props[:value]
      end
    end
  end
end
