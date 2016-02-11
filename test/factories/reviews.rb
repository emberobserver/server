FactoryGirl.define do
  factory :review do
    has_tests true
    has_readme true
    is_more_than_empty_addon true
    is_open_source true
    has_build true
  end
end
