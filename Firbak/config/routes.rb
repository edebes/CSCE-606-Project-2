Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  root "question_sets#index"

  get  "/login",  to: "logins#new"
  post "/login",  to: "logins#create"
  post "/logout", to: "logins#destroy", as: :logout

  resources :question_sets, only: [:index] do
    member do
      post :launch_session
    end
  end

  resources :sessions, only: [:show]
end
