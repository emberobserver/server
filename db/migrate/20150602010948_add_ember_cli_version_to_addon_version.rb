class AddEmberCliVersionToAddonVersion < ActiveRecord::Migration
  def change
    add_column :addon_versions, :ember_cli_version, :string
  end
end
