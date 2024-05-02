class MovieCastAndCrew < ApplicationRecord
  belongs_to :movie
  enum kind: { cast: 0, crew: 1 }
  enum role: { actor: 0, producer: 1, writer: 2, director: 3, musician: 4, lyricist: 5, cinematographer: 6 }
  has_one_attached :image
end
