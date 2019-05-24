Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root to: 'dashboard#index'

  get '/artists/:artist_id/movies/:id/views', to: 'dashboard#count_history'
  post '/artists/:artist_id/movies/:id/update_count', to: 'dashboard#update_count'
  post '/update_all_count', to: 'dashboard#update_all_count'
  get '/export', to: 'dashboard#export'

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
  delete '/artists/:artist_id/movies/:id/destroy', to: 'movies#destroy'
end
