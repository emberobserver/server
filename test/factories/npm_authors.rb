# frozen_string_literal: true
# == Schema Information
#
# Table name: npm_authors
#
#  id         :integer          not null, primary key
#  name       :string
#  email      :string
#  url        :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#


FactoryGirl.define do
  factory :npm_author do
  end
end
