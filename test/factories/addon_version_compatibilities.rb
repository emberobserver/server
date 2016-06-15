# == Schema Information
#
# Table name: addon_version_compatibilities
#
#  id               :integer          not null, primary key
#  addon_version_id :integer
#  package          :string
#  version          :string
#

FactoryGirl.define do
  factory :addon_version_compatibility do
    package 'package-name'
    version '1.0.0'
  end
end
