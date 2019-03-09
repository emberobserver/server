class AddIsMonorepoToAddon < ActiveRecord::Migration[5.1]
  def change
    add_column :addons, :is_monorepo, :boolean
  end
end
