# app/controllers/theaters_controller.rb
class TheatersController < ApplicationController
  before_action :set_theater, only: [:show]

  def index
    @theaters = Theater.all
  end

  def show
    @theater = Theater.find(params[:id])
    @rating = Rating.where(rateable_type: 'Theater', rateable_id: @theater.id, user_id: current_user.id).first
  end

  def rate
    @theater = Theater.find(params[:id])
    value = params[:value].to_i
    Rating.create(user_id: current_user.id, rateable_type: 'Theater', rateable_id: @theater.id, value: value)
    redirect_to theater_path(@theater), notice: 'Rating successfully added.'
  end

  private

  def set_theater
    @theater = Theater.find(params[:id])
  end

  def theater_params
    params.require(:theater).permit(:name, :location)
  end
end
