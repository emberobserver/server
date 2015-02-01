class CreateCategoryPackages < ActiveRecord::Migration
  def change
    create_table :category_packages do |t|
      t.references :category, index: true
      t.references :package, index: true

      t.timestamps null: false
    end
    add_foreign_key :category_packages, :categories
    add_foreign_key :category_packages, :packages
  end
end
