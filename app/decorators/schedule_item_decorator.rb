class ScheduleItemDecorator < Draper::Decorator
  delegate_all

  def start_day_percentage
     (start - ScheduleItem.beginning_of_day(start)) / (ScheduleItem.end_of_day(start) - ScheduleItem.beginning_of_day(start)) * 100
  end

  def duration_day_percentage
    (start + duration.minutes - start) / (ScheduleItem.end_of_day(start) - ScheduleItem.beginning_of_day(start)) * 100
  end
end