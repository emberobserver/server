class AddAddonNameToReviewsAndVersions < ActiveRecord::Migration
  def change
    add_column :reviews, :addon_name, :string
    add_column :addon_versions, :addon_name, :string
  end
end
