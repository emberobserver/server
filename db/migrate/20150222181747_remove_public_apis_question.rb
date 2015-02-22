class RemovePublicApisQuestion < ActiveRecord::Migration
  def change
    remove_column :reviews, :uses_only_public_apis
  end
end
