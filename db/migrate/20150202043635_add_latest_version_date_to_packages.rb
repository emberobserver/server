class AddLatestVersionDateToPackages < ActiveRecord::Migration
  def change
    add_column :packages, :latest_version_date, :datetime
  end
end
