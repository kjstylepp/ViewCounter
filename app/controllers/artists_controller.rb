class ArtistsController < ApplicationController
  include SessionManager

  before_action :set_artist, only: %i[show edit update destroy]

  def index
    @artists = Artist.all.order(created_at: 'DESC').page(params[:page])
    @new_artist = Artist.new
  end

  def create
    @artist = Artist.new(artist_params)

    if @artist.save
      redirect_to '/artists', notice: "#{@artist.name}を新規登録しました"
    else
      redirect_to '/artists', alert: 'アーティストを新規登録できませんでした'
    end
  end

  def show
    @movies = @artist.movies.order(published_at: 'DESC').page(params[:page])
    @new_movie = Movie.new
  end

  def edit; end

  def update
    if @artist.update(artist_params)
      redirect_to '/artists', notice: "アーティスト名を#{@artist.name}に更新しました"
    else
      redirect_to "/artists/#{@artist.id}/edit", alert: 'アーティスト名を更新できませんでした'
    end
  end

  def destroy
    if Rails.configuration.allow_manual_delete
      @artist.destroy

      redirect_to '/artists', notice: "#{@artist.name}を削除しました"
    else
      redirect_to '/artists', alert: '手動でのデータ削除は現在許可されていません'
    end
  end

  private

  def set_artist
    @artist = Artist.find_by_id(params[:id])

    redirect_to '/', alert: '不正な画面遷移です' if @artist.nil?
  end

  def artist_params
    params.require(:artist).permit(:name)
  end
end
