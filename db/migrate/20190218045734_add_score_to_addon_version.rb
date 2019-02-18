class AddScoreToAddonVersion < ActiveRecord::Migration[5.1]
  def change
    add_column :addon_versions, :score, :decimal, precision: 5, scale: 2
  end
end
