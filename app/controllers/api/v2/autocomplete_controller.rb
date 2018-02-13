# frozen_string_literal: true

class API::V2::AutocompleteController < ApplicationController
  def data
    render json: {
      addons: Addon.select(:id, :name, :description, :score, :is_wip).where(hidden: :false),
      categories: Category.select(:id, :name),
      maintainers: NpmMaintainer.select(:id, :name)
    }.as_json
  end
end
