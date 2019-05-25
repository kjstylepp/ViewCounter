class View < ApplicationRecord
  belongs_to :movie

  validates :count, presence: true
  validates :update_date, presence: true
end
