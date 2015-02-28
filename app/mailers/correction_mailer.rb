class CorrectionMailer < ActionMailer::Base
	def correction(args)
		@correction = args
		mail to: 'observers@emberobserver.com', from: 'Corrections <noreply@emberobserver.com>', subject: 'Ember Observer correction suggestion'
	end
end
