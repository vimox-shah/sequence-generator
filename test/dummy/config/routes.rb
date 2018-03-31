Rails.application.routes.draw do
  mount SequenceGenerator::Engine => "/sequence_generator"
end
