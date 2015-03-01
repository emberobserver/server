class AddIsTopStarredToAddons < ActiveRecord::Migration
  def change
    add_column :addons, :is_top_starred, :boolean, default: false
  end
end
