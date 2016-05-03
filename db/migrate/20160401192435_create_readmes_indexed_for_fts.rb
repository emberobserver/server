class CreateReadmesIndexedForFts < ActiveRecord::Migration
  def change
    create_view :readmes_indexed_for_fts, materialized: true
  end
end
