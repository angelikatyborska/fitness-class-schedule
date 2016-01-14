class ApplicationDecorator < Draper::Decorator
  delegate_all

  def css_id
    "#{ object.class.to_s.underscore.tr('_', '-') }-#{ object.id }"
  end
end