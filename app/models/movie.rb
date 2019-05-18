require 'httpclient'
require 'json'

class Movie < ApplicationRecord
  belongs_to :artist
  has_many :views

  validates :youtube_id, presence: true
  validates :youtube_id, uniqueness: true
  validates :title, presence: true

  def import_data
    unless self.youtube_id
      return
    end

    client = HTTPClient.new
    query = {id: self.youtube_id, key: Rails.configuration.google_api_key, part: 'snippet'}
    res = JSON.parse(client.get('https://www.googleapis.com/youtube/v3/videos', query: query, follow_redirect: true).body)

    unless res['items'].empty?
      movie_info = res['items'][0]

      if movie_info['id'] == self.youtube_id
        self.title = movie_info['snippet']['title']

        if movie_info['snippet']['thumbnails']['default']
          self.thumb_url = movie_info['snippet']['thumbnails']['default']['url']
        end
      end
    end
  end

  def update_count
    client = HTTPClient.new
    query = {id: self.youtube_id, key: Rails.configuration.google_api_key, part: 'statistics'}
    res = JSON.parse(client.get('https://www.googleapis.com/youtube/v3/videos', query: query, follow_redirect: true).body)

    unless res['items'].empty?
      movie_info = res['items'][0]

      if movie_info['id'] == self.youtube_id
        view = View.new
        view.movie_id = self.id
        view.count = movie_info['statistics']['viewCount'].to_i

        if view.save
          return true
        end
      end
    end

    return false
  end

  def self.update_all_count
    movies = Movie.all

    result = {}
    result[:all] = movies.size
    result[:success] = 0

    if movies.size > 0
      client = HTTPClient.new

      loop_number = ( movies.size - 1 ) / 50 + 1

      loop_number.times do |i|
        video_ids = ''
        50.times do |j|
          if movies[i * 50 + j]
            if j == 0
              video_ids = movies[i * 50 + j].youtube_id
            else
              video_ids = video_ids + ',' + movies[i * 50 + j].youtube_id
            end
          end
        end

        query = {id: video_ids, key: Rails.configuration.google_api_key, part: 'statistics'}
        res = JSON.parse(client.get('https://www.googleapis.com/youtube/v3/videos', query: query, follow_redirect: true).body)

        res['items'].each do |item|
          code = item['id']
          count = item['statistics']['viewCount'].to_i

          movie = Movie.find_by_youtube_id(code)
          if movie
            view = View.new(movie_id: movie.id, count: count)
            if view.save
              result[:success] += 1
            end
          end
        end
      end
    end

    return result
  end
end
