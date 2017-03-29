class API::V2::SearchController < ApplicationController

  def search
    query = params[:query]
    search_results = ReadmeView.find_matches_for(query)

    render json: search_results
  end

  def addons
    regex_search = params[:regex] == 'true'
    results = CodeSearch.retrieve_addons(params[:query], regex_search)
    render json: {results: results}
  end

  def source
    regex_search = params[:regex] == 'true'
    results = CodeSearch.retrieve_source(params[:query], params[:addon], regex_search)
    render json: {results: results}
  end

end
