class CreateScoreCalculation < ActiveRecord::Migration[5.1]
  def change
    create_table :score_calculations do |t|
      t.references :addon, foreign_key: true
      t.references :addon_version, foreign_key: true
      t.jsonb 'info'
      t.timestamps
    end
  end
end
