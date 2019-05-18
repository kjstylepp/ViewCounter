module SessionManager
  extend ActiveSupport::Concern

  included do
    before_action :ensure_login
  end

  def ensure_login
    unless session[:admin_session]
      redirect_to '/login', alert: '管理者ログインが必要です'
    end
  end
end
