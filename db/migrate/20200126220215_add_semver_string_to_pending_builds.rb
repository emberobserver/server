class AddSemverStringToPendingBuilds < ActiveRecord::Migration[5.1]
  def change
    add_column :pending_builds, :semver_string, :string
  end
end
