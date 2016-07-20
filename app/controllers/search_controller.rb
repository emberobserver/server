class SearchController < ApplicationController

  def search
    query = params[:query]
    search_results = ReadmeView.find_matches_for(query)

    render json: search_results
  end

end
