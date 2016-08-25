class ConsolidatedOutputForBuilds < ActiveRecord::Migration
  def change
    remove_column :test_results, :stderr, :text
    rename_column :test_results, :stdout, :output
  end
end
