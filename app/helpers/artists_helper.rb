module ArtistsHelper
  def update_movie_flag_text(flag)
    if flag
      return '集計対象から外す'
    else
      return '集計対象に追加する'
    end
  end

  def update_movie_flag_path(movie)
    if movie.flag
      return "/artists/#{movie.artist.id}/movies/#{movie.id}/disable"
    else
      return "/artists/#{movie.artist.id}/movies/#{movie.id}/enable"
    end
  end
end
