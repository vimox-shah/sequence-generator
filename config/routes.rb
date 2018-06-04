SequenceGenerator::Engine.routes.draw do
  resources :sequences do
    get '/fetch', to: 'sequences#fetch'
  end
end
