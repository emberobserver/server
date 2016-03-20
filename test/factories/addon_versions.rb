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
#

FactoryGirl.define do

  sequence(:version_number, 1) { |n| "1.0.#{n}" }

  factory :addon_version do
    addon
    version { generate(:version_number) }
    released { 2.weeks.ago }
  end

  trait :basic_one_point_zero do
    association :addon, :factory => [:addon, :basic]
    version '1.0.0'
    released { 1.weeks.ago }
  end

  trait :basic_one_point_one do
    association :addon, :factory => [:addon, :basic]
    version '1.1.0'
    released { 1.day.ago }
  end

  trait :with_review do
    after(:build) do |addon_version|
      addon_version.review = build :review, addon_version: addon_version
    end
  end

end
