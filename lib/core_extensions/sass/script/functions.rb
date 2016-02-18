module Sass::Script::Functions
  def color_from_site_settings(sass_string)
    ::Sass::Script::Value::Color.from_hex(SiteSettings.instance.public_send(sass_string.value))
  end
  declare :color_from_site_settings, [:sass_string]
end