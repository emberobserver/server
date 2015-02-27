class AddGithubDataToAddons < ActiveRecord::Migration
  def change
    add_column :addons, :github_user, :string
    add_column :addons, :github_repo, :string
  end
end
