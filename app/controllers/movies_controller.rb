class MoviesController < ApplicationController
  include SessionManager

  before_action :set_artist
  before_action :set_movie, only: %i[disable_flag enable_flag destroy]

  def create
    @movie = Movie.new(movie_params)
    @movie.artist_id = @artist.id
    @movie.flag = true

    if @movie.import_data
      redirect_to "/artists/#{@artist.id}", notice: "#{@movie.title}を新規登録しました"
    else
      redirect_to "/artists/#{@artist.id}", alert: '動画を新規登録できませんでした'
    end
  end

  def disable_flag
    if @movie.update(flag: false)
      redirect_to "/artists/#{@artist.id}", notice: "#{@movie.title}を集計対象から外しました"
    else
      redirect_to "/artists/#{@artist.id}", alert: "#{@movie.title}を集計対象から外せませんでした"
    end
  end

  def enable_flag
    if @movie.update(flag: true)
      redirect_to "/artists/#{@artist.id}", notice: "#{@movie.title}を集計対象に追加しました"
    else
      redirect_to "/artists/#{@artist.id}", alert: "#{@movie.title}を集計対象に追加できませんでした"
    end
  end

  def destroy
    redirect_to "/artists/#{@artist.id}", notice: "#{@movie.title}を削除しました"
  end

  private

  def set_artist
    @artist = Artist.find_by_id(params[:artist_id])

    redirect_to '/', alert: '不正な画面遷移です' if @artist.nil?
  end

  def set_movie
    @movie = Movie.find_by_id(params[:id])

    redirect_to '/', alert: '不正な画面遷移です' if @movie.nil? || @movie.artist_id != @artist.id
  end

  def movie_params
    params.require(:movie).permit(:youtube_id)
  end
end
