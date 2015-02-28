class CorrectionsController < ApplicationController
	def submit
		fields = [ :name, :email, :addon, :correction ]
		args = { }
		fields.each do |field|
			unless params.include?(field)
				head :unprocessable_entity
				return
			end
			args[field] = params[field]
		end
		CorrectionMailer.correction(args).deliver_now
		head :no_content
	end
end
