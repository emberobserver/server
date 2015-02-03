class RemoveNpmjsUrlFromPackages < ActiveRecord::Migration
  def up
    remove_column :packages, :npmjs_url
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
