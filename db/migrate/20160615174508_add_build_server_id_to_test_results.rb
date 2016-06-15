class AddBuildServerIdToTestResults < ActiveRecord::Migration
  def change
    add_reference :test_results, :build_server, index: true, foreign_key: true
  end
end
