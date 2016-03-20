class CreateReadmes < ActiveRecord::Migration
  def change
    create_table :readmes do |t|
      t.text :contents
      t.belongs_to :addon
    end
  end
end
