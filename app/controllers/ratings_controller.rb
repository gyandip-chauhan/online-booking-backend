class RatingsController < ApplicationController
  def new
    @movie = Movie.find(params[:movie_id])
    @rating = Rating.new
  end

  def create
    @movie = Movie.find(params[:movie_id])
    @rating = current_user.ratings.build(rating_params.merge(movie: @movie))

    if @rating.save
      redirect_to @movie, notice: 'Rating was successfully created.'
    else
      render :new
    end
  end

  private

  def rating_params
    params.require(:rating).permit(:value)
  end
end
