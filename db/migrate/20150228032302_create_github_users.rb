class CreateGithubUsers < ActiveRecord::Migration
  def change
    create_table :github_users do |t|
      t.string :login
    end

    create_table :addon_github_contributors do |t|
      t.references :addon, index: true
      t.references :github_user, index: true
    end
  end
end
