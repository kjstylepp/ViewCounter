class DashboardController < ApplicationController
  before_action :set_artist_and_movie, only: %i[count_history update_count]

  def index
    @movies = Movie.page(params[:page])
  end

  def count_history
    @views = @movie.views.order(update_date: 'DESC').page(params[:page])
  end

  def update_count
    if @movie.update_count
      redirect_to '/', notice: "#{@movie.title}の再生数を更新しました"
    else
      redirect_to '/', alert: "#{@movie.title}の再生数を更新できませんでした"
    end
  end

  def update_all_count
    result = Movie.update_all_count

    redirect_to '/', notice: "全#{result[:all]}件の動画の#{result[:success]}件の再生数を更新しました"
  end

  def export

  end

  def login
    session[:admin_session] = nil
  end

  def create_admin_session
    if params[:password] == 'password'
      session[:admin_session] = 'admin_session'

      redirect_to '/', notice: 'ログインに成功しました'
    else
      redirect_to '/login', alert: 'パスワードが間違っています'
    end
  end

  def destroy_admin_session
    session[:admin_session] = nil

    redirect_to '/', notice: 'ログアウトしました'
  end

  private

  def set_artist_and_movie
    artist = Artist.find_by_id(params[:artist_id])

    redirect_to '/', alert: '不正な画面遷移です' if artist.nil?

    @movie = Movie.find_by_id(params[:id])

    redirect_to '/', alert: '不正な画面遷移です' if @movie.nil? || @movie.artist_id != artist.id
  end
end
