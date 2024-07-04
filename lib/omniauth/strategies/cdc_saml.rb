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

      option :attribute_statements,
             first_name: ["givenname", "http://schemas.xmlsoap.org/ws/2005/05/identity/claims/givenname"],
             last_name: ["surname", "http://schemas.xmlsoap.org/ws/2005/05/identity/claims/surname"],
             email: ["emailaddress", "http://schemas.xmlsoap.org/ws/2005/05/identity/claims/emailaddress"]

      info do
        found_attributes = options.attribute_statements.map do |key, values|
          attribute = find_attribute_by(values)
          [key, attribute]
        end

        hash_attributes = found_attributes.to_h

        hash_attributes["name"] = "#{hash_attributes["first_name"]} #{hash_attributes["last_name"]}"

        hash_attributes["name"] = uid.split("@").first if hash_attributes["name"].blank?
        hash_attributes["email"] = uid if hash_attributes["email"].blank?

        hash_attributes
      end
    end
  end
end

OmniAuth.config.add_camelization "cdcsaml", "CDCSAML"
