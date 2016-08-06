class AddOutputColumnsToTestResults < ActiveRecord::Migration
  def change
    add_column :test_results, :stdout, :text
    add_column :test_results, :stderr, :text
  end
end
