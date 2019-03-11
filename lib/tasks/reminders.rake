# frozen_string_literal: true

namespace :reminders do
  task review: :environment do
    ReviewMailer.reviews_needed.deliver_now
  end
end
