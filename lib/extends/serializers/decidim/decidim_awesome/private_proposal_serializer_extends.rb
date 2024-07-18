# frozen_string_literal: true

module PrivateProposalSerializerExtends
  def serialize_private_custom_fields(payload)
    private_custom_fields = Decidim::DecidimAwesome::CustomFields.new(awesome_private_proposal_custom_fields)
    return payload if private_custom_fields.blank?

    private_body = proposal.awesome_private_proposal_field.present? ? proposal.awesome_private_proposal_field.private_body : ""
    fields_entries(private_custom_fields, private_body) do |key, value|
      payload["secret/#{key}".to_sym] = value
    end

    payload
  end
end

Decidim::DecidimAwesome::PrivateProposalSerializer.class_eval do
  prepend(PrivateProposalSerializerExtends)
end
