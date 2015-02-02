class RenameGithubUrlToRepositoryUrl < ActiveRecord::Migration
  def change
    rename_column :packages, :github_url, :repository_url
  end
end
