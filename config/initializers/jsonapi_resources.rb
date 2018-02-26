JSONAPI.configure do |config|
  # built in paginators are :none, :offset, :paged
  config.default_paginator = :none

  config.default_page_size = 977
  config.maximum_page_size = 10000
end
