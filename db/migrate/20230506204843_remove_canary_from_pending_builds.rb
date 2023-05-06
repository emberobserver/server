class RemoveCanaryFromPendingBuilds < ActiveRecord::Migration[5.1]
  def up
    remove_column :pending_builds, :canary
  end

  def down
    add_column :pending_builds, :canary, :boolean, default: false, null: false
    PendingBuild.where(build_type: :canary).update_all(canary: true)
  end
end
