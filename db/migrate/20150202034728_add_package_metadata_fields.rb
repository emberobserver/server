class AddPackageMetadataFields < ActiveRecord::Migration
  def change
    create_table :npm_users do |t|
      t.string :name
      t.string :email
      t.timestamps null: false
    end
    create_table :npm_keywords do |t|
      t.string :keyword
      t.timestamps null: false
    end
    create_table :package_maintainers, id: false do |t|
      t.integer :package_id
      t.integer :npm_user_id
    end
    create_table :package_npm_keywords, id: false do |t|
      t.integer :package_id
      t.integer :npm_keyword_id
    end
    add_column :packages, :license, :string
    add_column :packages, :author_id, :integer
  end
end
