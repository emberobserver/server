class SeparateNpmAuthorsAndMaintainers < ActiveRecord::Migration
  def up
    create_table :npm_authors do |t|
      t.string :name
      t.string :email
      t.string :url

      t.timestamps null: false
    end

    create_table :npm_maintainers do |t|
      t.string :name
      t.string :email
      t.string :gravatar

      t.timestamps null: false
    end

    rename_column :addon_maintainers, :npm_user_id, :npm_maintainer_id
    rename_column :addons, :author_id, :npm_author_id

    drop_table :npm_users
    AddonMaintainer.delete_all
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
