class RemoveCanaryFromTestResults < ActiveRecord::Migration[5.1]
  def up
    remove_column :test_results, :canary
  end

  def down
    add_column :test_results, :canary, :boolean, default: false, null: false
    TestResult.where(build_type: :canary).update_all(canary: true)
  end
end
