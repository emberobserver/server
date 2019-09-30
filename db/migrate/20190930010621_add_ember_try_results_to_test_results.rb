class AddEmberTryResultsToTestResults < ActiveRecord::Migration[5.1]
  def change
    add_column :test_results, :ember_try_results, :text
  end
end
