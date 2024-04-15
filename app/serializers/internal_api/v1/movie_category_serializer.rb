module InternalApi::V1
  class MovieCategorySerializer < ApplicationSerializer
    attributes :id, :name, :created_at, :updated_at
    # attribute :movies do |object|
    #   MovieSerializer.new(object.movies)
    # end
    attribute :showtimes do |object|
      ShowtimeSerializer.new(object.showtimes)
    end
  end
end
