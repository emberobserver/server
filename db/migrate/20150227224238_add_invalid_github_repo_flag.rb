class AddInvalidGithubRepoFlag < ActiveRecord::Migration
  def change
    add_column :addons, :has_invalid_github_repo, :boolean, default: false
  end
end
