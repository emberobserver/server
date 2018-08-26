class CreateAddonSizes < ActiveRecord::Migration[5.1]
  def change
    create_table :addon_sizes do |t|
      t.belongs_to :addon_version, index: true, foreign_key: true
      t.integer :app_js_size
      t.integer :app_css_size
      t.integer :vendor_js_size
      t.integer :vendor_css_size
    end
  end
end
