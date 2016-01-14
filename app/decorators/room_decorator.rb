class RoomDecorator < Draper::Decorator
  delegate_all

  def css_id
    "room-#{ id }"
  end
end