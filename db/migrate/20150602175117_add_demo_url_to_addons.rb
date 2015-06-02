class AddDemoUrlToAddons < ActiveRecord::Migration
  def change
    add_column :addons, :demo_url, :string
  end
end
