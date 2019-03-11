# frozen_string_literal: true

class ReviewMailer < ApplicationMailer
  def reviews_needed
    @addons = Addon.needs_review
    mail to: 'katie@kmg.io',
         from: 'Reviews <noreply@emberobserver.com>',
         reply_to: 'noreply@emberobserver.com',
         subject: "#{@addons.count} Ember Observer Reviews needed"
  end
end
