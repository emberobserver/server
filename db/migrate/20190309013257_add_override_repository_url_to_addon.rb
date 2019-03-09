class AddOverrideRepositoryUrlToAddon < ActiveRecord::Migration[5.1]
  def change
    add_column :addons, :override_repository_url, :string
  end
end
