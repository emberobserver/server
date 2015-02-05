class CreateReviews < ActiveRecord::Migration
  def change
    create_table :reviews do |t|
      t.integer :has_tests
      t.integer :has_readme
      t.integer :updated_recently
      t.integer :more_than_a_shell
      t.integer :substantive_functionality
      t.text :review

      t.integer :package_version_id, null: false

      t.timestamps
    end
  end
end
