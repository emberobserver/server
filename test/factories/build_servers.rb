# frozen_string_literal: true

# == Schema Information
#
# Table name: build_servers
#
#  id         :integer          not null, primary key
#  name       :string
#  token      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

FactoryGirl.define do
  sequence(:hostname) { |n| "build-server-#{n}" }

  factory :build_server do
    name { generate(:hostname) }
    token { SecureRandom.hex }
  end
end
