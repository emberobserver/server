class AddOtherAssetsToAssetSizes < ActiveRecord::Migration[5.1]
  def change
    add_column :addon_sizes, :other_js_size, :integer
    add_column :addon_sizes, :other_css_size, :integer
  end
end
