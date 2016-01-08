class ScheduleItemDecorator < Draper::Decorator
  delegate_all

  def css_id
    "schedule-item-#{ id }"
  end
end