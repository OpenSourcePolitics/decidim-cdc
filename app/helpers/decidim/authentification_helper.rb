# frozen_string_literal: true

module Decidim
  module AuthentificationHelper
    def can_access_admin?(user)
      return false if user.blank?

      user.admin? || user.role?("user_manager") || space_allows_admin_access?(user)
    end

    def space_allows_admin_access?(user)
      return false if user.blank?

      Decidim.participatory_space_manifests.any? do |manifest|
        Decidim.find_participatory_space_manifest(manifest.name)
               .participatory_spaces.call(user.organization)&.any? do |space|
          space.admins.exists?(id: user.id)
        end
      end
    end
  end
end
