class View < ApplicationRecord
  belongs_to :movie

  validates :count, presence: true
end
