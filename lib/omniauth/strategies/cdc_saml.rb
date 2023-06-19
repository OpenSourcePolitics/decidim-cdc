# frozen_string_literal: true

require "omniauth-saml"

module OmniAuth
  module Strategies
    class CDCSAML < OmniAuth::Strategies::SAML
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
