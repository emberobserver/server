class AddExtendsEmberToAddon < ActiveRecord::Migration[5.1]
  def change
    add_column :addons, :extends_ember_cli, :boolean
    add_column :addons, :extends_ember, :boolean
  end
end
