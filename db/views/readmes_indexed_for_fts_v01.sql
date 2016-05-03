select readmes.id as id,
to_tsvector('english', readmes.contents) as contents_tsvector,
addons.id as addon_id
from readmes
join addons on readmes.addon_id = addons.id;

create index gin_index_on_contents on readmes_indexed_for_fts using gin(contents_tsvector);
create unique index unique_index_on_id on readmes_indexed_for_fts (id);
