
# frozen_string_literal: true

module AddonScore
  class Check
    def initialize(addon)
      @addon = addon
    end

    protected

    attr_reader :addon
  end
end
