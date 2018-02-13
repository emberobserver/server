# frozen_string_literal: true
# == Schema Information
#
# Table name: readmes_indexed_for_fts
#
#  id                :integer          primary key
#  contents          :text
#  contents_tsvector :tsvector
#  addon_id          :integer
#
# Indexes
#
#  gin_index_on_contents  (contents_tsvector)
#  unique_index_on_id     (id) UNIQUE
#

class ReadmeView < ApplicationRecord
  self.table_name = 'readmes_indexed_for_fts'
  self.primary_key = 'id'

  include PgSearch

  pg_search_scope(
    :search,
    against: :contents,
    using: {
      tsearch: {
        dictionary: :english,
        tsvector_column: ['contents_tsvector'],
        highlight: {
          max_fragments: 1
        }
      }
    }
  )

  def self.find_matches_for(query)
    results = search(query).with_pg_search_highlight
    results.map { |r| { addon_id: r.addon_id, matches: r.pg_search_highlight.split(' ... ') } }
  end

  def self.refresh
    Scenic.database.refresh_materialized_view(table_name, concurrently: true)
  end

  def readonly?
    true
  end
end
