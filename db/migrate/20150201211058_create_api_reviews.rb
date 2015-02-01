class CreateAPIReviews < ActiveRecord::Migration
  def change
    create_table :api_reviews do |t|
      t.references :package, index: true
      t.string :version
      t.text :body

      t.timestamps null: false
    end
    add_foreign_key :api_reviews, :packages
  end
end
