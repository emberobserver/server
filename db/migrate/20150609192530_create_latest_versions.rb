class CreateLatestVersions < ActiveRecord::Migration
  def change
    create_table :latest_versions do |t|
      t.string :package
      t.string :version

      t.timestamps null: false
    end
  end
end
