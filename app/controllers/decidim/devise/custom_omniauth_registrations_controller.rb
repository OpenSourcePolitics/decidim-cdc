# frozen_string_literal: true

module Decidim
  module Devise
    class CustomOmniauthRegistrationsController < ::Decidim::Devise::OmniauthRegistrationsController
      include Decidim::AuthentificationHelper

      def create
        form_params = user_params_from_oauth_hash || params[:user]

        @form = form(OmniauthRegistrationForm).from_params(form_params)
        @form.email ||= verified_email

        CreateOmniauthRegistration.call(@form, verified_email) do
          on(:ok) do |user|
            if user.active_for_authentication? && can_access_admin?(user)
              unless user.accepted_or_not_invited?
                user.accept_invitation
                user.accepted_tos_version = user.organization.tos_version
                user.save
              end

              sign_in_and_redirect user, event: :authentication
              set_flash_message :notice, :success, kind: @form.provider.capitalize
            else
              expire_data_after_sign_in!
              redirect_to "/admin_sign_in"
              flash[:error] = t("devise.registrations.user_not_admin")
            end
          end

          on(:invalid) do
            set_flash_message :notice, :success, kind: @form.provider.capitalize
            redirect_to "/admin_sign_in"
          end

          on(:error) do |user|
            if user.errors[:email]
              set_flash_message :alert, :failure, kind: @form.provider.capitalize, reason: t("decidim.devise.omniauth_registrations.create.email_already_exists")
            end
            redirect_to "/admin_sign_in"
          end
        end
      end

      def after_sign_in_path_for(user)
        if user.present? && user.blocked?
          check_user_block_status(user)
        elsif !pending_redirect?(user) && can_access_admin?(user)
          "/admin"
        else
          super
        end
      end
    end
  end
end
