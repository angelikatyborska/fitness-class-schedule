class ScheduleItems::Multicolumn
  def initialize(schedule_items)
    chunks = split_into_independent_chunks(schedule_items)

    @independent_multicolumns = chunks.each_with_object([]) do |items, multicolumns|
      multicolumns << ScheduleItems::IndependentMulticolumn.new(items)
    end
  end

  def split_into_independent_chunks(schedule_items)
    items_to_split = schedule_items.sort_by { |item| [item.start, item.room.name] }

    temp_chunk = []

    time_points(items_to_split).each_with_object([]) do |point, chunks|
      while items_to_split.any? && point == items_to_split[0].start
        temp_chunk << items_to_split.shift
      end

      if temp_chunk.any? { |item| point == item.stop }
        if temp_chunk.count { |item| item.going_on_at?(point) } == 0
          chunks << temp_chunk
          temp_chunk = []
        end
      end
    end
  end

  def width(schedule_item)
    multicolumn_with_item(schedule_item).width(schedule_item)
  end

  def left(schedule_item)
    multicolumn_with_item(schedule_item).left(schedule_item)
  end

  private

  def multicolumn_with_item(schedule_item)
    @independent_multicolumns.find { |multicolumn| multicolumn.contains?(schedule_item) }
  end

  def time_points(schedule_items)
    time_points = schedule_items.each.with_object([]) do |item, time_points|
      time_points << item.start
      time_points << item.stop
    end

    time_points.sort!
  end
end
