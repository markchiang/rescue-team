Rails.application.routes.draw do
  resources :uploaders
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  get  "/ifttt/v1/status", to: "uploaders#status"
  post "/ifttt/v1/test/setup", to: "uploaders#setup"

  post "/ifttt/v1/triggers/earthquake_coming", to: "uploaders#earthquake_coming"

end
