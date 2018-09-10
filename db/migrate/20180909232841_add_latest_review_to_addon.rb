class AddLatestReviewToAddon < ActiveRecord::Migration[5.1]
  def change
    add_reference :addons, :latest_review, references: :reviews, index: true
    add_foreign_key :addons, :reviews, column: :latest_review_id
  end
end
