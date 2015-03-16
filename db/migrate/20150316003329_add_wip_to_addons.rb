class AddWipToAddons < ActiveRecord::Migration
  def change
    add_column :addons, :is_wip, :boolean
  end
end
