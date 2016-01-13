module Sass::Script::Functions
  def color_from_configurables(sass_string)
    ::Sass::Script::Value::Color.from_hex(Configurable.public_send(sass_string.value))
  end
  declare :color_from_configurables, [:sass_string]
end