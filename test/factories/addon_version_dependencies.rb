# frozen_string_literal: true

# == Schema Information
#
# Table name: addon_version_dependencies
#
#  id               :integer          not null, primary key
#  package          :string
#  version          :string
#  dependency_type  :string
#  addon_version_id :integer
#  package_addon_id :integer
#
# Indexes
#
#  index_addon_version_dependencies_on_addon_version_id     (addon_version_id)
#  index_addon_version_dependencies_on_package              (package)
#  index_addon_version_dependencies_on_package_addon_id     (package_addon_id)
#  index_addon_version_dependencies_on_package_and_version  (package,version)
#
# Foreign Keys
#
#  fk_rails_...  (package_addon_id => addons.id)
#

FactoryBot.define do
  factory :addon_version_dependency do
    package 'ember-try'
    dependency_type 'dependency'
    association :addon_version
  end

  trait :is_addon do
    association :package_addon, factory: :addon
  end

  trait :is_not_addon do
  end
end
