class CreateAddonVersionCompatibility < ActiveRecord::Migration
  def change
    create_table :addon_version_compatibilities do |t|
      t.references :addon_version, index: true, foreign_key: true
      t.string :package
      t.string :version
    end
  end
end
