class AddUniqueIndexOnAddonName < ActiveRecord::Migration[5.1]
  def change
    add_index :addons, :name, unique: true
  end
end
