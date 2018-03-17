class AddIndexesOnAddonVersionDependencies < ActiveRecord::Migration[5.1]
  disable_ddl_transaction!

  def change
    add_index :addon_version_dependencies, :package, algorithm: :concurrently
    add_index :addon_version_dependencies, [:package, :version], algorithm: :concurrently
  end
end
