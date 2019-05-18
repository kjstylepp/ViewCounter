class MoviesController < ApplicationController
  include SessionManager

  before_action :set_artist
  before_action :set_movie, only: [:destroy]

  def create
    @movie = Movie.new(movie_params)
    @movie.artist_id = @artist.id

    @movie.import_data

    if @movie.save
      redirect_to "/artists/#{@artist.id}", notice: "#{@movie.title}を新規登録しました"
    else
      redirect_to "/artists/#{@artist.id}", alert: '動画を新規登録できませんでした'
    end
  end

  def destroy
    redirect_to "/artists/#{@artist.id}", notice: "#{@movie.title}を削除しました"
  end

  private
  def set_artist
    @artist = Artist.find_by_id(params[:artist_id])

    if @artist.nil?
      redirect_to '/', alert: '不正な画面遷移です'
    end
  end

  def set_movie
    @movie = Movie.find_by_id(params[:id])

    if @movie.nil? || @movie.artist_id != @artist.id
      redirect_to '/', alert: '不正な画面遷移です'
    end
  end

  def movie_params
    params.require(:movie).permit(:youtube_id)
  end
end
