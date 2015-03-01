class AddAvatarUrlToGithubUsers < ActiveRecord::Migration
  def change
    add_column :github_users, :avatar_url, :string
  end
end
