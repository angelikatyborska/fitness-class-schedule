module ApplicationHelper
  def schedule_item_width(item, schedule_items)
    n = schedule_items.count { |other_item| other_item.going_on_between?(item.start, item.stop) }

    100.0 / n
  end

  def schedule_item_left_position(item, schedule_items)
    all_items_at_that_time = schedule_items.select { |other_item| other_item.going_on_between?(item.start, item.stop) }

    i = all_items_at_that_time.find_index { |other_item| other_item == item}

    schedule_item_width(item, schedule_items) * i
  end

  def in_set_timezone(time)
    time.in_time_zone(ActiveSupport::TimeZone[Configurable.time_zone])
  end


  def schedule_item_start_day_percentage(item)
    (item.start.in_website_time_zone - ScheduleItem.beginning_of_day(item.start.in_website_time_zone)) / (ScheduleItem.end_of_day(item.start.in_website_time_zone) - ScheduleItem.beginning_of_day(item.start.in_website_time_zone)) * 100
  end

  def schedule_item_duration_day_percentage(item)
    (item.start.in_website_time_zone + item.duration.minutes - item.start.in_website_time_zone) / (ScheduleItem.end_of_day(item.start.in_website_time_zone) - ScheduleItem.beginning_of_day(item.start.in_website_time_zone)) * 100
  end

  def order_by_weekdays(schedule_items, week_offset)
    week = Time.zone.now.in_website_time_zone.beginning_of_week + week_offset.weeks
    weekdays = {}

    7.times do |n|
      weekdays[week + n.days] = []
    end

    schedule_items.week(week).order(:start).map do |item|
      weekdays[item.start.in_website_time_zone.beginning_of_day] << item
    end

    weekdays
  end
end
