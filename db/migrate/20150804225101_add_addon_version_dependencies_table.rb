class AddAddonVersionDependenciesTable < ActiveRecord::Migration
  def change
    create_table :addon_version_dependencies do |t|
      t.string :package
      t.string :version
      t.string :dependency_type

      t.references :addon_version, index: true
    end
  end
end
