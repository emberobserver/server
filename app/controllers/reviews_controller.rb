class ReviewsController < ApplicationController
  before_action :authenticate, only: [:create]

  def show
		review = Review.find(params[:id])
		render json: review
  end

  def index
    reviews = Review.all
    render json: reviews
  end

  def create
    review = Review.create!(review_params)

    AddonScoreUpdater.perform_now(review.addon_version.addon.id)
    AddonCacheBuilder.perform_later

    render json: review
  end

  private

  def mutate_params
    params[:review][:addon_version_id] = params[:review].delete(:version_id)
  end

  def review_params
    mutate_params
    params.require(:review).permit(:has_tests, :has_readme,
                                   :is_more_than_empty_addon, :review, :is_open_source,
                                   :has_build, :addon_version_id)
  end
end
