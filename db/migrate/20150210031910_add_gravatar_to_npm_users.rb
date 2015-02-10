class AddGravatarToNpmUsers < ActiveRecord::Migration
  def change
    add_column :npm_users, :gravatar, :string
  end
end
