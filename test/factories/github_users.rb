# frozen_string_literal: true

# == Schema Information
#
# Table name: github_users
#
#  id         :integer          not null, primary key
#  login      :string
#  avatar_url :string
#

FactoryBot.define do
  factory :github_user do
  end
end
