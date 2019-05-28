module ArtistsHelper
  def update_movie_flag_text(flag)
    if flag
      '集計対象から外す'
    else
      '集計対象に追加する'
    end
  end

  def update_movie_flag_path(movie)
    if movie.flag
      "/artists/#{movie.artist.id}/movies/#{movie.id}/disable"
    else
      "/artists/#{movie.artist.id}/movies/#{movie.id}/enable"
    end
  end

  def movie_flag_text(flag)
    if flag
      '○'
    else
      '×'
    end
  end
end
