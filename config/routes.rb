Rails.application.routes.draw do
  devise_for :users
  require 'sidekiq/web'
  
  Sidekiq::Web.use Rack::Auth::Basic do |username, password|
    username == ENV['SIDEKIQ_USERNAME'] &&
    password == ENV['SIDEKIQ_PASSWORD']
  end
  
  mount Sidekiq::Web => '/sidekiq'

  post '/register', to: 'users#create'
  get "/me", to: "users#me"
  get '/user/:id', to: 'users#show'
  patch '/user/update', to: 'users#update'
  delete '/user/delete', to: 'users#destroy'
 
  post "/auth/login", to: "auth#login"

  get '/blogs', to: 'blogs#index'
  get '/blog/:id', to: 'blogs#show'
  post 'blog', to: 'blogs#create'
  delete '/blog/:id', to: 'blogs#destroy'
  patch '/blog/update/:id', to: 'blogs#update'

  post '/blog/:id/create/comment', to: 'comments#create'
  get '/blog/:blog_id/comments', to: 'comments#index'
  patch '/comments/:id', to: 'comments#update'
  delete '/comments/:id', to: 'comments#destroy'

  get '/blogs/populars', to: 'blogs#popular'
end
  