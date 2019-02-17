# frozen_string_literal: true

FactoryBot.define do
  factory :addon_version_dependency do
    package 'ember-try'
    dependency_type 'dependency'
    association :addon_version
  end

  trait :is_addon do
    association :package_addon, factory: :addon
  end

  trait :is_not_addon do
  end
end
