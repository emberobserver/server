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
#  index_addon_version_dependencies_uniqueness              (addon_version_id,package,version,dependency_type) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (package_addon_id => addons.id)
#

class AddonVersionDependency < ApplicationRecord
  belongs_to :addon_version

  # rubocop:disable Rails/InverseOf
  belongs_to :package_addon, class_name: 'Addon', optional: true

  has_one :latest_version,
    ->(dependency) {
      unscope(:where).merge(AddonVersion.latest_versions.where('addon_versions.addon_name = ?', dependency.package))
    }, class_name: 'AddonVersion'

  has_one :latest_version_size,
    ->(dependency) {
      unscope(:where)
        .merge(AddonSize.joins(:addon_version).merge(AddonVersion.latest_versions.where('addon_versions.addon_name = ?', dependency.package)))
    }, class_name: 'AddonSize'
  # rubocop:enable Rails/InverseOf
end
