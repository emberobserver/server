class SearchController < ApplicationController

  def search
    query = params[:query]
    search_results = ReadmeView.find_matches_for(query)

    render json: search_results
  end

  def addons
    results = CodeSearch.retrieve_addons(params[:query])
    render json: {results: results}
  end

  def source
    results = CodeSearch.retrieve_source(params[:query], params[:addon])
    render json: {results: results}
  end

end
