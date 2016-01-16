class ScheduleItems::Styles
  def initialize(schedule_items)
    @day_multicolumn = ScheduleItems::Multicolumn.new(schedule_items)
  end

  def width(schedule_item)
    @day_multicolumn.width(schedule_item)
  end

  def left(schedule_item)
    @day_multicolumn.left(schedule_item)
  end

  def top(item)
    start = item.start.in_website_time_zone
    day_start = ScheduleItem.beginning_of_day(start)
    day_end = ScheduleItem.end_of_day(start)

    (start - day_start) / (day_end - day_start) * 100
  end

  def height(item)
    start = item.start.in_website_time_zone
    day_start = ScheduleItem.beginning_of_day(start)
    day_end = ScheduleItem.end_of_day(start)

    (start + item.duration.minutes - start) / (day_end - day_start) * 100
  end

  def for(item)
    "top: #{ top(item) }%;" \
    "left: #{ left(item) }%;" \
    "height: #{ height(item) }%;"\
    "width: #{ width(item) }%;"
  end
end
