class AddFieldsToReviews < ActiveRecord::Migration
  def change
    remove_column :reviews, :updated_recently
    remove_column :reviews, :substantive_functionality
    rename_column :reviews, :more_than_a_shell, :is_more_than_empty_addon
    add_column :reviews, :is_open_source, :integer
    add_column :reviews, :uses_only_public_apis, :integer
    add_column :reviews, :has_build, :integer
  end
end
