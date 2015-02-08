class ApplicationSerializer < ActiveModel::Serializer
  embed :ids, embed_in_root: true
end
