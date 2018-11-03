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
#
# Indexes
#
#  index_addon_version_dependencies_on_addon_version_id     (addon_version_id)
#  index_addon_version_dependencies_on_package              (package)
#  index_addon_version_dependencies_on_package_and_version  (package,version)
#

require 'test_helper'

class AddonVersionDependencyTest < ActiveSupport::TestCase
  test 'latest addon size when only one addon version exists and it has a size' do
    dependency_addon = create(:addon, name: 'dependency-addon')
    latest_version_of_dependency = create(:addon_version, addon: dependency_addon)
    addon_size = create(:addon_size, addon_version: latest_version_of_dependency)
    dependency_addon.latest_addon_version = latest_version_of_dependency
    dependency_addon.save!

    dependent_version = create(:addon_version, addon: create(:addon, name: 'dependent-addon'))
    dependency = create(:addon_version_dependency, package: 'dependency-addon', addon_version: dependent_version)

    assert_equal addon_size.id, dependency.latest_version_size.id
  end

  test 'latest addon size when only one addon version exists and it does not have a size' do
    dependency_addon = create(:addon, name: 'dependency-addon')
    latest_version_of_dependency = create(:addon_version, addon: dependency_addon)

    dependency_addon.latest_addon_version = latest_version_of_dependency
    dependency_addon.save!

    dependent_version = create(:addon_version, addon: create(:addon, name: 'dependent-addon'))
    dependency = create(:addon_version_dependency, package: 'dependency-addon', addon_version: dependent_version)

    assert_nil dependency.latest_version_size
  end

  test 'latest addon size when multiple versions with sizes exist' do
    dependency_addon = create(:addon, name: 'dependency-addon')
    older_version_of_dependency = create(:addon_version, addon: dependency_addon)
    latest_version_of_dependency = create(:addon_version, addon: dependency_addon)

    create(:addon_size, addon_version: older_version_of_dependency)
    addon_size = create(:addon_size, addon_version: latest_version_of_dependency)

    dependency_addon.latest_addon_version = latest_version_of_dependency
    dependency_addon.save!

    dependent_version = create(:addon_version, addon: create(:addon, name: 'dependent-addon'))
    dependency = create(:addon_version_dependency, package: 'dependency-addon', addon_version: dependent_version)

    assert_equal addon_size.id, dependency.latest_version_size.id
  end

  test 'latest addon size when there are older versions with sizes but latest has no size' do
    dependency_addon = create(:addon, name: 'dependency-addon')
    older_version_of_dependency = create(:addon_version, addon: dependency_addon)
    latest_version_of_dependency = create(:addon_version, addon: dependency_addon)

    create(:addon_size, addon_version: older_version_of_dependency)

    dependency_addon.latest_addon_version = latest_version_of_dependency
    dependency_addon.save!

    dependent_version = create(:addon_version, addon: create(:addon, name: 'dependent-addon'))
    dependency = create(:addon_version_dependency, package: 'dependency-addon', addon_version: dependent_version)

    assert_nil dependency.latest_version_size
  end
end
