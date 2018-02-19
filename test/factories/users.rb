# frozen_string_literal: true

# == Schema Information
#
# Table name: users
#
#  id              :integer          not null, primary key
#  email           :string
#  password_digest :string
#  auth_token      :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "test_#{n}@example.com" }
    auth_token 'solongandthanksforallthefish'
    password_digest SecureRandom.hex
  end
end
