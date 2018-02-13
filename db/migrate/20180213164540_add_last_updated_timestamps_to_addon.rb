class AddLastUpdatedTimestampsToAddon < ActiveRecord::Migration[5.1]
  def change
    add_column :addons, :package_info_last_updated_at, :datetime
    add_column :addons, :repo_info_last_updated_at, :datetime
  end
end
