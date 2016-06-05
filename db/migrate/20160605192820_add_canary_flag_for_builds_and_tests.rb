class AddCanaryFlagForBuildsAndTests < ActiveRecord::Migration
  def change
    add_column :pending_builds, :canary, :boolean, default: false, null: false
    add_column :test_results, :canary, :boolean, default: false, null: false
  end
end
