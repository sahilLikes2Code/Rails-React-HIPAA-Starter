SecureHeaders::Configuration.default do |config|
  # HSTS: max-age=31536000; includeSubDomains; preload
  config.hsts = "max-age=31536000; includeSubDomains; preload"
  config.x_frame_options = "DENY"
  config.x_content_type_options = "nosniff"
  config.x_xss_protection = "1; mode=block"
  config.x_permitted_cross_domain_policies = "none"
  config.referrer_policy = %w[no-referrer strict-origin-when-cross-origin]

  config.csp = {
    base_uri: %w['self'],
    default_src: %w['self'],
    script_src: %w['self' 'unsafe-inline'],
    style_src: %w['self' 'unsafe-inline'],
    img_src: %w['self' data: https:],
    font_src: %w['self' data:],
    connect_src: %w['self'],
    frame_ancestors: %w['none'],
    form_action: %w['self'],
    upgrade_insecure_requests: true
  }

  # Permissions Policy (Feature Policy) - only if supported by gem version
  # Note: Some versions of secure_headers may not support this
  if config.respond_to?(:permissions_policy)
    config.permissions_policy = {
      accelerometer: [],
      camera: [],
      geolocation: [],
      gyroscope: [],
      magnetometer: [],
      microphone: [],
      payment: [],
      usb: []
    }
  end
end

