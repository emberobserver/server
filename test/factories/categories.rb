FactoryGirl.define do
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
