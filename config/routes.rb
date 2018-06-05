SequenceGenerator::Engine.routes.draw do
  resources :sequences, only: [:create, :update, :index]
  # get '/sequences/fetch', to: 'sequences#fetch', controller: 'sequences'
end
