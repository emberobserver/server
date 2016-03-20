class CreatePendingBuilds < ActiveRecord::Migration
  def change
    create_table :pending_builds do |t|
      t.references :addon_version, index: true, foreign_key: true

      t.datetime :build_assigned_at
      t.references :build_server, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
