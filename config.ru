# This file is used by Rack-based servers to start the application.

require_relative "config/environment"

run Rails.application
Rails.application.load_server

use Rack::Session::Cookie,
  key: '_kursatch_session',
  secret: ENV.fetch('SESSION_SECRET') { SecureRandom.hex(64) },
  same_site: :lax,
  secure: Rails.env.production?

run Rails.application