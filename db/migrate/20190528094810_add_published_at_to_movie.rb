require 'httpclient'

class AddPublishedAtToMovie < ActiveRecord::Migration[5.2]
  def up
    add_column :movies, :published_at, :date

    movies = Movie.all
    video_ids = ''
    movies.each_with_index do |movie, i|
      video_ids = if i.zero?
                    movie.youtube_id
                  else
                    video_ids + ',' + movie.youtube_id
                  end
    end

    client = HTTPClient.new
    query = { id: video_ids, key: Rails.configuration.google_api_key, part: 'snippet' }
    res = JSON.parse(client.get('https://www.googleapis.com/youtube/v3/videos', query: query, follow_redirect: true).body)

    return if res['items'].blank?

    res['items'].each do |item|
      code = item['id']
      movie = Movie.find_by_youtube_id(code)

      next unless movie

      movie.published_at = DateTime.parse(item['snippet']['publishedAt']).new_offset("+09:00").to_date

      movie.save
    end
  end

  def down
    remove_column :movies, :published_at
  end
end
