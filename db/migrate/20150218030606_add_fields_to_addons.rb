class AddFieldsToAddons < ActiveRecord::Migration
  def change
    add_column :addons, :deprecated, :boolean, default: false
    add_column :addons, :note, :text
    add_column :addons, :official, :boolean, default: false
    add_column :addons, :cli_dependency, :boolean, default: false
    add_column :addons, :hidden, :boolean, default: false
  end
end
