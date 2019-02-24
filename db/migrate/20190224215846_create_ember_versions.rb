class CreateEmberVersions < ActiveRecord::Migration[5.1]
  def change
    create_table :ember_versions do |t|
      t.string :version, null: false
      t.datetime :released, null: false

      t.timestamps
    end
  end
end
