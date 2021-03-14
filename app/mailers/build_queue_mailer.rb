# frozen_string_literal: true

class BuildQueueMailer < ApplicationMailer
  def queue_not_empty
    @queue_size = PendingBuild.count
    mail to: 'phil@pgengler.net',
         from: 'Ember Observer <noreply@emberobserver.com>',
         reply_to: 'noreply@emberobserver.com',
         subject: 'Ember Observer build queue not empty'
  end
end
