class AddLatestAddonVersionToAddon < ActiveRecord::Migration
  def change
    add_reference :addons, :latest_addon_version, references: :addon_versions, index: true
    add_foreign_key :addons, :addon_versions, column: :latest_addon_version_id
  end
end
