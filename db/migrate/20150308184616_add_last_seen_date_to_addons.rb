class AddLastSeenDateToAddons < ActiveRecord::Migration
  def change
    add_column :addons, :last_seen_in_npm, :datetime
  end
end
