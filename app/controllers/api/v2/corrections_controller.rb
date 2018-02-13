# frozen_string_literal: true

class API::V2::CorrectionsController < ApplicationController
  def submit
    fields = %i[name email addon correction]
    args = {}
    fields.each do |field|
      unless params.include?(field)
        head :unprocessable_entity
        return
      end
      args[field] = params[field]
    end
    addon = Addon.find_by(name: args[:addon])
    unless addon
      head :unprocessable_entity
      return
    end
    args.delete :addon
    CorrectionMailer.correction(args, addon).deliver_now
    head :no_content
  end
end
