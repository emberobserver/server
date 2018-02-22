# frozen_string_literal: true

namespace :reviews do
  desc 'Create new reviews for addons that need review and got all points on their last review'
  task autoreview: :environment do
    AutoReviewer.rereview_addons
  end
end
