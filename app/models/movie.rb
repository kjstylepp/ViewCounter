class Movie < ApplicationRecord
  belongs_to :artist
  has_many :views
end
