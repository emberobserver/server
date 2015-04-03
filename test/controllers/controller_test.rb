class ControllerTest < ActionController::TestCase
	protected
	def json_response
		@json_response ||= ActiveSupport::JSON.decode(@response.body)
	end
end
