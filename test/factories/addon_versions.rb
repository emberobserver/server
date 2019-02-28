# frozen_string_literal: true

# == Schema Information
#
# Table name: addon_versions
#
#  id                :integer          not null, primary key
#  addon_id          :integer
#  version           :string
#  released          :datetime
#  addon_name        :string
#  ember_cli_version :string
#  score             :decimal(5, 2)
#
# Indexes
#
#  index_addon_versions_on_addon_id  (addon_id)
#

FactoryBot.define do
  sequence(:version_number, 1) { |n| "1.0.#{n}" }

  factory :addon_version do
    addon
    version { generate(:version_number) }
    released { 2.weeks.ago }

    factory :addon_version_with_ember_version_compatibility do
      transient do
        ember_version_compatibility '>= 1.13.0'
      end
      after(:build) do |addon_version, evaluator|
        create(:addon_version_compatibility, addon_version: addon_version, package: 'ember', version: evaluator.ember_version_compatibility)
      end
    end
  end

  trait :basic_one_point_zero do
    association :addon, factory: %i[addon basic]
    version '1.0.0'
    released { 1.week.ago }
  end

  trait :basic_one_point_one do
    association :addon, factory: %i[addon basic]
    version '1.1.0'
    released { 1.day.ago }
  end

  trait :with_review do
    after(:build) do |addon_version|
      addon_version.review = build :review, addon_version: addon_version
    end
  end
end
