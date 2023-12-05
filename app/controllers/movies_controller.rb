class MoviesController < ApplicationController
  before_action :set_movie, only: [:show, :like]

  def index
    @movies = Movie.all
  end

  def show
    @movie = Movie.find(params[:id])
    @rating = Rating.where(rateable_type: 'Movie', rateable_id: @movie.id, user_id: current_user.id).first
  end

  def rate
    @movie = Movie.find(params[:id])
    value = params[:value].to_i
    Rating.create(user_id: current_user.id, rateable_type: 'Movie', rateable_id: @movie.id, value: value)
    redirect_to movie_path(@movie), notice: 'Rating successfully added.'
  end

  private

  def set_movie
    @movie = Movie.find(params[:id])
  end

  def movie_params
    params.require(:movie).permit(:title)
  end
end
