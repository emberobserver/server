# frozen_string_literal: true

# == Schema Information
#
# Table name: categories
#
#  id          :integer          not null, primary key
#  name        :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  description :text
#  parent_id   :integer
#  position    :integer
#
# Indexes
#
#  index_categories_on_parent_id  (parent_id)
#

FactoryBot.define do
  factory :category do
    name { SecureRandom.hex }
    description 'Thing'
  end

  factory :subcategory, parent: :category do
    association :parent_category, factory: :category
  end

  factory :parent_category, parent: :category do
    after(:build) do |category|
      create :category, parent_category: category
    end
  end
end
