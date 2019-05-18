class Artist < ApplicationRecord
  has_many :movies

  validates :name, presence: true
  validates :name, uniqueness: true
end
