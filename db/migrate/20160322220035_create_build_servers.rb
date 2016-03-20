class CreateBuildServers < ActiveRecord::Migration
  def change
    create_table :build_servers do |t|
      t.string :name
      t.string :token

      t.timestamps null: false
    end
  end
end
