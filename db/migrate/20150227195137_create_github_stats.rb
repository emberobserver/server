class CreateGithubStats < ActiveRecord::Migration
  def change
    create_table :github_stats do |t|
      t.references :addon, index: true
      t.integer :open_issues
      t.integer :contributors
      t.integer :commits
      t.integer :forks
      t.integer :releases

      t.datetime :first_commit_date
      t.string :first_commit_sha
      t.datetime :latest_commit_date
      t.string :latest_commit_sha
    end
    add_foreign_key :github_stats, :addons
  end
end
