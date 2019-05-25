class Artist < ApplicationRecord
  has_many :movies, dependent: :destroy

  validates :name, presence: true
  validates :name, uniqueness: true
end
