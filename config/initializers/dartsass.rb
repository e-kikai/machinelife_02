if Rails.env.development?
  Rails.application.config.dartsass.builds = {
    "daihou/daihou.scss" => "daihou/dart_daihou.css",
    "application.scss" => "dart_application.css"
  }
end
