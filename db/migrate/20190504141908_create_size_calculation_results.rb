class CreateSizeCalculationResults < ActiveRecord::Migration[5.1]
  def change
    create_table :size_calculation_results do |t|
      t.references :addon_version, index: true, foreign_key: true
      t.boolean :succeeded
      t.text :error_message
      t.text :output

      t.belongs_to :build_server, index: true, foreign_key: true
      t.timestamps null: false
    end
  end
end
