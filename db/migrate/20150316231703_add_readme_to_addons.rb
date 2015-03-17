class AddReadmeToAddons < ActiveRecord::Migration
  def change
    add_column :github_stats, :readme, :text
  end
end
