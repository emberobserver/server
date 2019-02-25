# frozen_string_literal: true

# == Schema Information
#
# Table name: ember_versions
#
#  id         :integer          not null, primary key
#  version    :string           not null
#  released   :datetime         not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

FactoryBot.define do
  factory :ember_version do
    sequence(:version) { |n| "v#{n}.0.0" }
    released '2019-02-24 16:58:46'
  end

  trait :beta do
    sequence(:version) { |n| "#{n}.0.0-beta.1" }
  end

  trait :major do
    sequence(:version) { |n| "#{n}.0.0" }
  end

  trait :minor do
    sequence(:version) { |n| "3.#{n}.0" }
  end

  trait :point_release do
    sequence(:version) { |n| "3.1.#{n}" }
  end
end
