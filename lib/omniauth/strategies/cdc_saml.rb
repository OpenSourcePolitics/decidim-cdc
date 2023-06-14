# frozen_string_literal: true

require "omniauth-saml"

module OmniAuth
  module Strategies
    class CDCSAML < OmniAuth::Strategies::SAML

    end
  end
end

OmniAuth.config.add_camelization "cdcsaml", "CDCSAML"
