# app/controllers/movies_controller.rb
module InternalApi::V1
  class MoviesController < ApplicationController
    before_action :set_movie, only: [:show]
    skip_before_action :authenticate_user!, :authenticate_user_using_x_auth_token, only: [:index, :show]

    def index
      RailsPerformance.measure("Movie listing", "internal_api/v1/movies#index") do
        @movies = Movie.includes({avatar_attachment: :blob}).all
      end
      render json: {movies: MovieSerializer.new(@movies, {params: {disable_showtimes: true, disable_casts: true, disable_crews: true}})}, status: :ok
    end

    def show
      render json: { movie: MovieSerializer.new(@movie, {params: {disable_showtimes: true}}) }, status: :ok
    end

    private

    def set_movie
      @movie = Movie.includes({avatar_attachment: :blob}, movie_cast_and_crews: {image_attachment: :blob}).find(params[:id])
    end

    def movie_params
      params.require(:movie).permit(:title)
    end
  end
end
