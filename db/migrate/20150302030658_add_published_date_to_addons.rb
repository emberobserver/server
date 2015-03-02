class AddPublishedDateToAddons < ActiveRecord::Migration
  def change
    add_column :addons, :published_date, :datetime
  end
end
