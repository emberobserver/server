class AddRankingToAddons < ActiveRecord::Migration
  def change
    add_column :addons, :ranking, :integer
  end
end
