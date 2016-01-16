class ScheduleItems::IndependentMulticolumn
  def initialize(schedule_items)
    fill_columns(schedule_items)
  end

  def fill_columns(schedule_items)
    items_by_rooms = schedule_items.each_with_object({}) do |item, items_by_rooms|
      items_by_rooms[item.room] ||= []
      items_by_rooms[item.room] << item
    end

    items_by_rooms.each do |room, items|
      @columns ||= []
      @columns << ScheduleItems::Column.new(items)
    end
  end

  def left(schedule_item)
    100.0 * @columns.find_index { |column| column.contains?(schedule_item) } / @columns.length
  end

  def width(schedule_item)
    100.0 / @columns.length
  end

  def contains?(schedule_item)
    @columns.any? { |column| column.contains?(schedule_item) }
  end
end
