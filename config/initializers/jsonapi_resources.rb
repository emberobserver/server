JSONAPI.configure do |config|
  # built in paginators are :none, :offset, :paged
  config.default_paginator = :none

  config.default_page_size = 1000
  config.maximum_page_size = 1000
end
