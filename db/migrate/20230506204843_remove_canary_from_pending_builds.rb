class RemoveCanaryFromPendingBuilds < ActiveRecord::Migration[5.1]
  def change
    remove_column :pending_builds, :canary, default: false, null: false
  end
end
