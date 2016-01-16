module ApplicationHelper
  def schedule_items_styles(schedule_items)
    ScheduleItems::Styles.new(schedule_items)
  end

  # TODO: write specs
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
