# TODO: refactor
class ScheduleItemsStyles
  def initialize(schedule_items)
    @time_points = time_points(schedule_items)
    @items_at_time_points = list_items_at_time_points(schedule_items)
    @items_at_time_points = sort_items_at_time_points_by_time_remaining(@items_at_time_points)
    @items_max_widths = calculate_items_max_widths(schedule_items)
    @items_widths = {}
    @items_lefts = calculate_items_lefts(schedule_items)
  end

  def width(schedule_item)
    @items_widths[schedule_item]
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
    "top: #{ top(item) }%;" \
    "left: #{ left(item) }%;" \
    "height: #{ height(item) }%;"\
    "width: #{ width(item) }%;"
  end

  private

  def time_points(schedule_items)
    time_points = schedule_items.each.with_object([]) do |item, time_points|
      time_points << item.start
      time_points << item.stop
    end

    time_points.sort!
  end

  def list_items_at_time_points(schedule_items)
    @time_points.each.with_object({}) do |point, points_items|
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
      max_width = (10000.0 / items.count).floor / 100.0

      items.each do |item|
        items_max_widths[item]  = max_width if items_max_widths[item] > max_width
      end
    end

    items_max_widths
  end

  def calculate_items_lefts(schedule_items)
    @items_at_time_points.each_with_object({}) do |(time_point, items), items_lefts|
      items.each do |item|
        if items_lefts[item].nil?

          free_space = get_free_space_for_item(item, @items_max_widths[item])

          items_lefts[item] = free_space[:from]
          @items_widths[item] = free_space[:width]

          reserve_space_for_item(item, free_space[:from], free_space[:width])
        end
      end
    end
  end

  def get_free_space_for_item(item, width)
    if @reserved_space_at_time_points && @reserved_space_at_time_points[item.start]
      get_exactly_matching_free_space_for_item(item, width) || get_a_narrower_free_space_for_item(item)
    else
      { from: 0, width: width }
    end
  end

  def get_exactly_matching_free_space_for_item(item, width)
    start = 0

    @reserved_space_at_time_points[item.start].each do |reservation|
      if reservation[:from] - start >= width
        return { from: start, width: width }
      else
        start = reservation[:from] + reservation[:width]
      end
    end

    if 100 - start >= width
      { from: start, width: width }
    else
      nil
    end
  end

  def get_a_narrower_free_space_for_item(item)
    start = 0
    from = 0
    max = 0

    @reserved_space_at_time_points[item.start].each do |reservation|
      if reservation[:from] - start > max
        max = reservation[:from] - start
        from = start
      end

      start = reservation[:from] + reservation[:width]
    end

    { from: from, width: max }
  end

  def reserve_space_for_item(item, from, width)
    each_item_time_point(item) do |point|
      reserve_space_at_time_point(point, from, width)
    end
  end

  def reserve_space_at_time_point(time_point, from, width)
    @reserved_space_at_time_points ||= {}
    @reserved_space_at_time_points[time_point] ||= []

    @reserved_space_at_time_points[time_point] << { from: from, width: width }
  end

  def each_item_time_point(item, &block)
    @time_points.each do |point|
      if point >= item.start && point <= item.stop
        yield point
      end
    end
  end
end
