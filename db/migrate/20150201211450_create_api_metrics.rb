class CreateAPIMetrics < ActiveRecord::Migration
  def change
    create_table :api_metrics do |t|
      t.string :name
      t.string :description
      t.text :details

      t.timestamps null: false
    end
  end
end
