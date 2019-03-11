class AddRemovedFromNpmToAddon < ActiveRecord::Migration[5.1]
  def change
    add_column :addons, :removed_from_npm, :boolean, default: false
  end
end
