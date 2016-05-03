class ReadmeView < ActiveRecord::Base
  self.table_name = 'readmes_indexed_for_fts'
  self.primary_key = 'id'

  include PgSearch

  pg_search_scope(
    :search,
    against: :contents,
    :using => {
      :tsearch => {
        dictionary: :english,
        tsvector_column: ["contents_tsvector"]
      }
    }
  )

  def self.refresh
    Scenic.database.refresh_materialized_view(table_name, concurrently: true)
  end

  def readonly?
    true
  end
end
