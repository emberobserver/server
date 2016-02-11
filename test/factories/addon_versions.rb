FactoryGirl.define do

  factory :addon_version do
    addon
    version '1.2.3'
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
