# app/controllers/ratings_controller.rb
module InternalApi::V1
  class RatingsController < ApplicationController
    def new
      @movie = Movie.find(params[:movie_id])
      @rating = Rating.new
    end

    def create
      @movie = Movie.find(params[:movie_id])
      @rating = current_user.ratings.build(rating_params.merge(movie: @movie))

      if @rating.save
        render json: { message: 'Rating was successfully created.', rating: @rating }, status: :ok
      else
        render json: { errors: @rating.errors.full_messages }, status: :unprocessable_entity
      end
    end

    private

    def rating_params
      params.require(:rating).permit(:value)
    end
  end
end
