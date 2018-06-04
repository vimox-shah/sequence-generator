SequenceGenerator::Engine.routes.draw do
  resources :sequences
  get '/fetch', to: 'sequences#fetch'
end
