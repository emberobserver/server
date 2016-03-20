class CreateTestResults < ActiveRecord::Migration
  def change
    create_table :test_results do |t|
      t.references :addon_version, index: true, foreign_key: true
      t.boolean :succeeded
      t.string :status_message

      t.timestamps null: false
    end
  end
end
