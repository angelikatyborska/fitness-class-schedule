class ScheduleItemDecorator < Draper::Decorator
  delegate_all

  def stop
    start + duration.minutes
  end

  def start_day_percentage
     (start - start.beginning_of_day) / (start.end_of_day - start.beginning_of_day) * 100
  end

  def duration_day_percentage
    (start + duration.minutes - start) / (start.end_of_day - start.beginning_of_day) * 100
  end
end