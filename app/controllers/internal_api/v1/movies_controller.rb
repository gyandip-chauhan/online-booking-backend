# app/controllers/movies_controller.rb
module InternalApi::V1
  class MoviesController < ApplicationController
    before_action :set_movie, only: [:show, :like]
    skip_before_action :authenticate_user!, :authenticate_user_using_x_auth_token, only: [:index, :show]

    def index
      @movies = Movie.all
      render json: {movies: MovieSerializer.new(@movies)}, status: :ok
    end

    def show
      @movie = Movie.find(params[:id])
      # @rating = Rating.where(rateable_type: 'Movie', rateable_id: @movie.id, user_id: current_user.id).first
      render json: { movie: MovieSerializer.new(@movie) }, status: :ok
    end

    def rate
      @movie = Movie.find(params[:id])
      value = params[:value].to_i
      rating = Rating.create(user_id: current_user.id, rateable_type: 'Movie', rateable_id: @movie.id, value: value)

      if rating.valid?
        render json: { message: 'Rating successfully added.', rating: rating }, status: :ok
      else
        render json: { errors: rating.errors.full_messages }, status: :unprocessable_entity
      end
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
