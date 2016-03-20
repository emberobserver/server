class CreateEmberVersionCompatibilities < ActiveRecord::Migration
  def change
    create_table :ember_version_compatibilities do |t|
      t.references :test_result, index: true, foreign_key: true
      t.string :ember_version
      t.boolean :compatible

      t.timestamps null: false
    end
  end
end
