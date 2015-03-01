class AddIsTopDownloadedToAddons < ActiveRecord::Migration
  def change
    add_column :addons, :is_top_downloaded, :boolean, default: false
  end
end
