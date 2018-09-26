class CreatePendingSizeCalculations < ActiveRecord::Migration[5.1]
  def change
    create_table :pending_size_calculations do |t|
      t.references :addon_version, index: true, foreign_key: true

      t.datetime :build_assigned_at
      t.references :build_server, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
