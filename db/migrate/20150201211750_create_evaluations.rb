class CreateEvaluations < ActiveRecord::Migration
  def change
    create_table :evaluations do |t|
      t.references :metric, index: true
      t.references :review, index: true
      t.float :score

      t.timestamps null: false
    end
    add_foreign_key :evaluations, :metrics
    add_foreign_key :evaluations, :reviews
  end
end
