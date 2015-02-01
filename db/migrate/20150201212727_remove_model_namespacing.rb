class RemoveModelNamespacing < ActiveRecord::Migration
  def change
    rename_table :api_metrics, :metrics

    remove_index :api_reviews, :package_id
    rename_table :api_reviews, :reviews
    add_index :reviews, [:package_id]
  end
end
