class UpdateReadmesIndexedForFtsToVersion2 < ActiveRecord::Migration
  def change
    update_view :readmes_indexed_for_fts, version: 2, revert_to_version: 1, materialized: true
  end
end
