FactoryGirl.define do

  factory :addon do
    name { SecureRandom.hex }
    deprecated false
    official false
    hidden false
  end

  trait :basic do
    name 'basic-addon'
  end

  trait :offical do
    name 'official-addon'
    official true
  end

  trait :deprecated do
    name 'deprecated-addon'
    deprecated true
  end

  trait :hidden do
    name 'hidden-addon'
    hidden true
  end

end
