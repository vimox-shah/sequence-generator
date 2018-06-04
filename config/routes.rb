SequenceGenerator::Engine.routes.draw do
  resources :sequences
  get '/sequences/fetch', to: 'sequences#fetch', controller: 'sequences'
end
