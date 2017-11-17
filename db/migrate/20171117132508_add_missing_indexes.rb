class AddMissingIndexes < ActiveRecord::Migration
  def change
    add_index :addon_maintainers, :addon_id
    add_index :addon_maintainers, :npm_maintainer_id
    add_index :addon_maintainers, [:addon_id, :npm_maintainer_id]
    add_index :addon_npm_keywords, :addon_id
    add_index :addon_npm_keywords, :npm_keyword_id
    add_index :addon_versions, :addon_id
    add_index :addons, :npm_author_id
    add_index :categories, :parent_id
    add_index :readmes, :addon_id
    add_index :reviews, :addon_version_id
  end
end
