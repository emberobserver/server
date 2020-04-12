class AddGzippedSizesToAddonSize < ActiveRecord::Migration[5.1]
  def change
    add_column :addon_sizes, :app_js_gzip_size, :integer
    add_column :addon_sizes, :app_css_gzip_size, :integer

    add_column :addon_sizes, :vendor_js_gzip_size, :integer
    add_column :addon_sizes, :vendor_css_gzip_size, :integer

    add_column :addon_sizes, :other_js_gzip_size, :integer
    add_column :addon_sizes, :other_css_gzip_size, :integer

    add_column :addon_sizes, :other_assets, :jsonb
  end
end
