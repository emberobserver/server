class CreatePackageVersionsTable < ActiveRecord::Migration
  def change
    create_table :package_versions do |t|
      t.integer :package_id
      t.string :version
      t.datetime :released
    end
  end
end
