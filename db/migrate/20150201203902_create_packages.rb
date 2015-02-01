class CreatePackages < ActiveRecord::Migration
  def change
    create_table :packages do |t|
      t.string :name
      t.string :npmjs_url
      t.string :github_url

      t.timestamps null: false
    end
  end
end
