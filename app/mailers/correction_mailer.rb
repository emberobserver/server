class CorrectionMailer < ActionMailer::Base
	def correction(args, addon)
		@correction = args
		@addon = addon
		mail to: 'observers@emberobserver.com', from: 'Corrections <noreply@emberobserver.com>', reply_to: args[:email], subject: 'Ember Observer correction suggestion'
	end
end
