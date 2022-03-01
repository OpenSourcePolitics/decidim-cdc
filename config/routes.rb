# frozen_string_literal: true

require "sidekiq/web"
require "sidekiq-scheduler/web"

Rails.application.routes.draw do
  authenticate :admin do
    mount Sidekiq::Web => "/sidekiq"
  end

  mount LetterOpenerWeb::Engine, at: "/letter_opener" if Rails.env.development?

  devise_for :users,
             class_name: "Decidim::User",
             module: :devise,
             router_name: :decidim,
             controllers: {
               invitations: "decidim/devise/invitations",
               sessions: "decidim/devise/custom_sessions",
               admin_sessions: "decidim/devise/admin_sessions",
               confirmations: "decidim/devise/confirmations",
               registrations: "decidim/devise/registrations",
               passwords: "decidim/devise/passwords",
               unlocks: "decidim/devise/unlocks",
               omniauth_callbacks: "decidim/devise/custom_omniauth_registrations"
             }

  devise_scope :user do
    get "/admin_sign_in", to: "decidim/devise/admin_sessions#new"
  end

  mount Decidim::Core::Engine => "/"
  # mount Decidim::Map::Engine => '/map'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
