class AddInfoToPackages < ActiveRecord::Migration
  def change
    add_column :packages, :latest_version, :string
    add_column :packages, :description, :string
  end
end
