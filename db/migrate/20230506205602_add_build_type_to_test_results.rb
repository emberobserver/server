class AddBuildTypeToTestResults < ActiveRecord::Migration[5.1]
  def up
    add_column :test_results, :build_type, :string
    TestResult.where(canary: true).update_all(build_type: :canary)
    TestResult.where(canary: false).update_all(build_type: :ember_version_compatibility)
  end

  def down
    remove_column :test_results, :build_type
  end
end
