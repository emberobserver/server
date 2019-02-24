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
    version "MyString"
    released "2019-02-24 16:58:46"
  end
end
