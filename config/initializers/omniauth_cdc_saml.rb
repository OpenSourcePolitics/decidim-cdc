# frozen_string_literal: true

require "omniauth/strategies/cdc_saml"

Rails.application.config.middleware.use OmniAuth::Builder do
  OmniAuth.config.logger = Rails.logger

  omniauth_config = Rails.application.secrets[:omniauth]

  if omniauth_config[:cdcsaml].present?
    provider(
      OmniAuth::Strategies::CDCSAML,
      setup: setup_provider_proc(:cdcsaml,
                                 icon_path: :icon_path,
                                 provider_name: :provider_name,
                                 idp_cert_fingerprint: :idp_cert_fingerprint,
                                 idp_cert: :idp_cert,
                                 certificate: :idp_cert,
                                 private_key: :idp_key,
                                 issuer: :issuer,
                                 assertion_consumer_service_url: :assertion_consumer_service_url,
                                 idp_sso_service_url: :idp_sso_service_url,
                                 idp_slo_service_url: :idp_slo_service_url)
    )
  end
end
