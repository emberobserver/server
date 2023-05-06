class AddBuildTypeToPendingBuilds < ActiveRecord::Migration[5.1]
  def up
    add_column :pending_builds, :build_type, :string
    PendingBuild.where(canary: true).update_all(build_type: :canary)
    PendingBuild.where(canary: false).update_all(build_type: :ember_version_compatibility)
  end

  def down
    remove_column :pending_builds, :build_type
  end
end
