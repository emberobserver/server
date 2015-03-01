class AddLastMonthDownloadsToAddons < ActiveRecord::Migration
  def change
    add_column :addons, :last_month_downloads, :integer
  end
end
