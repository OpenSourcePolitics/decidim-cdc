# frozen_string_literal: true

source "https://rubygems.org"

DECIDIM_VERSION = "0.27"
DECIDIM_BRANCH = "release/#{DECIDIM_VERSION}-stable"

ruby RUBY_VERSION

# Many gems depend on environment variables, so we load them as soon as possible
gem "dotenv-rails", require: "dotenv/rails-now"

# Core gems
gem "decidim", "~> #{DECIDIM_VERSION}.0"

# External Decidim gems
gem "decidim-cache_cleaner"
gem "decidim-decidim_awesome", git: "https://github.com/octree-gva/decidim-module-decidim_awesome.git", branch: "feat/awesome_decidim_private_fields"
gem "decidim-friendly_signup", git: "https://github.com/OpenSourcePolitics/decidim-module-friendly_signup.git"
gem "decidim-spam_detection"
gem "decidim-term_customizer", git: "https://github.com/opensourcepolitics/decidim-module-term_customizer.git", branch: "fix/multi-threading-compliant"

# Omniauth gems
gem "omniauth-saml"

# Default
gem "activejob-uniqueness", require: "active_job/uniqueness/sidekiq_patch"
gem "aws-sdk-s3", require: false
gem "bootsnap", "~> 1.4"
gem "deface"
gem "faker", "~> 2.14"
gem "fog-aws"
gem "foundation_rails_helper", git: "https://github.com/sgruhier/foundation_rails_helper.git"
gem "nokogiri", "1.13.4"
gem "omniauth-rails_csrf_protection", "~> 1.0"
gem "puma", ">= 5.5.1"

gem "letter_opener_web", "~> 1.3"
gem "rack-attack", "~> 6.6"
gem "ruby-progressbar"
gem "sidekiq", "~> 6.0"
gem "sidekiq_alive", "~> 2.2"
gem "sidekiq-scheduler", "~> 5.0"
gem "sys-filesystem"
gem "uglifier", "~> 4.1"

group :development do
  gem "listen", "~> 3.1"
  gem "rubocop-faker"
  gem "spring", "~> 2.0"
  gem "spring-watcher-listen", "~> 2.0"
  gem "web-console", "4.0.4"
end

group :development, :test do
  gem "brakeman", "~> 5.1"
  gem "byebug", "~> 11.0", platform: :mri
  gem "climate_control", "~> 1.2"
  gem "decidim-dev", "~> #{DECIDIM_VERSION}.0"
  gem "parallel_tests"
end

group :production do
  gem "dalli"
  gem "health_check", "~> 3.1"
  gem "lograge"
  gem "sendgrid-ruby"
  gem "sentry-rails"
  gem "sentry-ruby"
  gem "sentry-sidekiq"
end
