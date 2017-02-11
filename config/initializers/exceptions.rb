class Forbidden < JSONAPI::Exceptions::Error
  def errors
    [JSONAPI::Error.new(code: JSONAPI::FORBIDDEN,
                        status: :forbidden,
                        title: 'Forbidden',
                        detail: 'Forbidden')]
  end
end
