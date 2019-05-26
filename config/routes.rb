Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root to: 'dashboard#index'

  get '/artists/:artist_id/movies/:id/views', to: 'dashboard#count_history'
  post '/update_counts', to: 'dashboard#update_counts'
  get '/export_counts', to: 'dashboard#export_counts'

  get '/login', to: 'dashboard#login'
  post '/login', to: 'dashboard#create_admin_session'
  get '/logout', to: 'dashboard#destroy_admin_session'

  get '/artists', to: 'artists#index'
  post '/artists', to: 'artists#create'
  get '/artists/:id', to: 'artists#show'
  get '/artists/:id/edit', to: 'artists#edit'
  patch '/artists/:id', to: 'artists#update'
  delete '/artists/:id/destroy', to: 'artists#destroy'

  post '/artists/:artist_id/movies', to: 'movies#create'
  post '/artists/:artist_id/movies/:id/disable', to: 'movies#disable_flag'
  post '/artists/:artist_id/movies/:id/enable', to: 'movies#enable_flag'
  delete '/artists/:artist_id/movies/:id/destroy', to: 'movies#destroy'
end
