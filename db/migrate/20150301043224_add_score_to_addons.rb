class AddScoreToAddons < ActiveRecord::Migration
  def change
    add_column :addons, :score, :integer
  end
end
