class CreateAudits < ActiveRecord::Migration[5.1]
  def change
    create_table :audits do |t|
      t.references :addon, foreign_key: true
      t.references :addon_version, foreign_key: true
      t.string :type
      t.boolean :value
      t.boolean :override_value
      t.references :user, foreign_key: true
      t.datetime :override_timestamp
      t.jsonb 'results'
      t.timestamps
    end
  end
end
