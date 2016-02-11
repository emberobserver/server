FactoryGirl.define do
  factory :user do
    sequence(:email) { |n| "test_#{n}@example.com"}
    auth_token 'solongandthanksforallthefish'
    password_digest SecureRandom.hex
  end
end
