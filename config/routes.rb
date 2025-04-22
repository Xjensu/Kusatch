Rails.application.routes.draw do
  require 'sidekiq/web'
  
  Sidekiq::Web.use Rack::Auth::Basic do |username, password|
    username == ENV['SIDEKIQ_USERNAME'] &&
    password == ENV['SIDEKIQ_PASSWORD']
  end
  
  mount Sidekiq::Web => '/sidekiq'

  post '/register', to: 'users#create'
  get "/me", to: "users#me"
  get '/user/:id', to: 'users#show'
  
  post "/auth/login", to: "auth#login"
  post '/auth/revoke', to: 'auth#revoke'

  get '/blogs', to: 'blogs#index'
  get '/blogs/:id', to: 'blogs#show'
  post 'blog', to: 'blogs#create'
  delete '/blog/:id', to: 'blogs#destroy'
end
  