class AddUniqueIndexForAddonVersionDependencies < ActiveRecord::Migration[5.1]
  def change
    add_index :addon_version_dependencies, [ :addon_version_id, :package, :version, :dependency_type ], unique: true, name: 'index_addon_version_dependencies_uniqueness'
  end
end
