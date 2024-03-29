# frozen_string_literal: true

require "cell/partial"

module Decidim
  # This cell renders the list of endorsers.
  #
  # Example:
  #
  #    cell("decidim/endorsers_list", my_component)
  class EndorsersListCell < Decidim::ViewModel
    include ApplicationHelper

    def show
      return unless endorsers.any?

      render
    end

    private

    # Finds the correct author for each endorsement.
    #
    # Returns an Array of presented Users/UserGroups
    def endorsers
      # Customization OSP: Add limit 100 to endorsers list
      @endorsers ||= model.endorsements.for_listing
                          .includes(:author, :user_group)
                          .limit(100)
                          .map { |identity| present(identity.normalized_author) }
    end
  end
end
