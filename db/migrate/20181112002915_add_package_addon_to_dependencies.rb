class AddPackageAddonToDependencies < ActiveRecord::Migration[5.1]
  def change
    add_reference :addon_version_dependencies, :package_addon, references: :addons, index: true
    add_foreign_key :addon_version_dependencies, :addons, column: :package_addon_id
  end
end
