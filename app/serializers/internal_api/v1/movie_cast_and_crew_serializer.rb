module InternalApi::V1
  class MovieCastAndCrewSerializer < ApplicationSerializer
    attributes :id, :name, :movie_id, :role, :kind, :created_at, :updated_at
    
    attribute :image_url do |object|
      if object.image.attached?
        ENV['HOST_URL'] + Rails.application.routes.url_helpers.rails_blob_path(object.image, only_path: true)
      else
        nil
      end
    end
  end
end
