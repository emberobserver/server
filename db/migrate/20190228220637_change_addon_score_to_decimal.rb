class ChangeAddonScoreToDecimal < ActiveRecord::Migration[5.1]
  def up
    change_column :addons, :score, :decimal, precision: 5, scale: 2
  end

  def down
    change_column :addons, :score, :integer
  end
end
