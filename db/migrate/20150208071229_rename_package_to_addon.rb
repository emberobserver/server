class RenamePackageToAddon < ActiveRecord::Migration
  def change
    rename_table :packages, :addons

    rename_column :category_packages, :package_id, :addon_id
    rename_table :category_packages, :category_addons

    rename_column :package_maintainers, :package_id, :addon_id
    rename_table :package_maintainers, :addon_maintainers

    rename_column :package_npm_keywords, :package_id, :addon_id
    rename_table :package_npm_keywords, :addon_npm_keywords

    rename_column :package_versions, :package_id, :addon_id
    rename_table :package_versions, :addon_versions


    rename_column :reviews, :package_version_id, :addon_version_id
  end
end
