class MakeIsWipNotNullable < ActiveRecord::Migration
  def change
    change_column_null :addons, :is_wip, false, false
    change_column_default :addons, :is_wip, false
  end
end
