same_site = ENV.fetch("SESSION_COOKIE_SAME_SITE", "lax").to_sym

Rails.application.config.session_store :cookie_store,
  key: "cantinho_da_leitura_session",
  httponly: true,
  secure: Rails.env.production?,
  same_site: same_site
