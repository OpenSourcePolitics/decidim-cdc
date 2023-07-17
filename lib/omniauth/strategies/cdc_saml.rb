# frozen_string_literal: true

require "omniauth-saml"

module OmniAuth
  module Strategies
    class CDCSAML < OmniAuth::Strategies::SAML
      option :protocol_binding, "urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST"
      option :name_identifier_format, "urn:oasis:names:tc:SAML:1.1:nameid-format:unspecified"

      option :idp_cert_fingerprint_algorithm, XMLSecurity::Document::SHA256
      option :security,
             digest_method: XMLSecurity::Document::SHA256,
             signature_method: XMLSecurity::Document::RSA_SHA256

      info do
        found_attributes = options.attribute_statements.map do |key, values|
          attribute = find_attribute_by(values)
          [key, attribute]
        end

        hash_attributes = Hash[found_attributes]

        hash_attributes["name"] = "#{hash_attributes["first_name"]} #{hash_attributes["last_name"]}"
        hash_attributes["nickname"] = hash_attributes["first_name"]

        hash_attributes
      end
    end
  end
end

OmniAuth.config.add_camelization "cdcsaml", "CDCSAML"
