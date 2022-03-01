# frozen_string_literal: true

module Decidim
  module Devise
    class CustomSessionsController < ::Decidim::Devise::SessionsController
      include Decidim::AuthentificationHelper

      def create
        super() do |resource|
          if can_access_admin?(resource)
            ::Devise.sign_out_all_scopes ? sign_out : sign_out(resource_name)
            expire_data_after_sign_in!
            redirect_to "/admin_sign_in"
            flash[:error] = t("devise.registrations.force_sso_for_admin")
            return
          end
        end
      end
    end
  end
end
