# TODO: refactor
class ScheduleItemsStyles
  def initialize(schedule_items)
    @items_at_time_points = list_items_at_time_points(schedule_items)
    @items_at_time_points = sort_items_at_time_points_by_time_remaining(@items_at_time_points)
    @items_max_widths = calculate_items_max_widths(schedule_items)
    @items_lefts = calculate_items_lefts(schedule_items)
  end

  def width(schedule_item)
    @items_max_widths[schedule_item]
  end

  def left(schedule_item)
    @items_lefts[schedule_item]
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
    style = ""
    style << "top: #{ top(item) }%;"
    style << "left: #{ left(item) }%;"
    style << "height: #{ height(item) }%;"
    style << "width: #{ width(item) }%;"
  end

  private

  def list_items_at_time_points(schedule_items)
    time_points = schedule_items.each.with_object([]) do |item, time_points|
      time_points << item.start
      time_points << item.stop
    end

    time_points.sort!

    time_points.each.with_object({}) do |point, points_items|
      if points_items[point].nil?
        points_items[point] = schedule_items.select { |item| item.going_on_at?(point) }
      end
    end
  end

  def sort_items_at_time_points_by_time_remaining(items_at_time_points)
    items_at_time_points.each do |time_point, items|
      items.sort_by! { |item| [-(item.stop - time_point), item.room.name, item.room.created_at] }
    end
  end

  def calculate_items_max_widths(schedule_items)
    items_max_widths = schedule_items.each.with_object({}) do |schedule_item, widths|
      widths[schedule_item] = 100.0
    end

    items_at_time_points = list_items_at_time_points(schedule_items)
    items_at_time_points.each do |time_point, items|
      max_width = 100.0 / items.count

      items.each do |item|
        if items_max_widths[item] > max_width
          items_max_widths[item]  = max_width
        end
      end
    end

    items_max_widths
  end

  def calculate_items_lefts(schedule_items)
    items_lefts = {}

    @items_at_time_points.each do |time_point, items|
      starting_left_for_point = items.map { |item| items_lefts[item] ? @items_max_widths[item] : 0 }.sum

      items.each do |item|
        if items_lefts[item].nil?
          items_lefts[item] = starting_left_for_point
          starting_left_for_point += @items_max_widths[item]
        end
      end
    end

    items_lefts
  end
end
