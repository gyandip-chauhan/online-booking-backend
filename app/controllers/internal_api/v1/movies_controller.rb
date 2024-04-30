# app/controllers/movies_controller.rb
module InternalApi::V1
  class MoviesController < ApplicationController
    before_action :set_movie, only: [:show, :like]
    skip_before_action :authenticate_user!, :authenticate_user_using_x_auth_token, only: [:index, :show]

    def index
      RailsPerformance.measure("Movie listing", "internal_api/v1/movies#index") do
        @movies = Movie.includes(:showtimes).all
      end
      render json: {movies: MovieSerializer.new(@movies)}, status: :ok
    end

    def show
      @movie = Movie.find(params[:id])
      render json: { movie: MovieSerializer.new(@movie) }, status: :ok
    end

    private

    def set_movie
      @movie = Movie.find(params[:id])
    end

    def movie_params
      params.require(:movie).permit(:title)
    end
  end
end
