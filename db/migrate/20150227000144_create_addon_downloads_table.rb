class CreateAddonDownloadsTable < ActiveRecord::Migration
  def change
    create_table :addon_downloads do |t|
      t.references :addon, index: true
      t.date :date
      t.integer :downloads
    end
    add_foreign_key :addon_downloads, :addons
  end
end
