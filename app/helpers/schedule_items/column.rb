class ScheduleItems::Column
  def initialize(schedule_items)
    schedule_items.sort_by! { |item| [item.start, item.room.name] }

    schedule_items.each_cons(2) do |items|
      fail_on_overlapping_items(items[0], items[1]) if items[0].stop > items[1].start
    end

    @schedule_items = schedule_items
  end

  def free_between?(start, stop)
    @scheudle_items.all? do |item|
      !item.going_on_at?(start, stop)
    end
  end

  def insert(item)
    index = 0

    while @schedule_items[index].stop < item.start
      index += 1
    end

    if @schedule_items[index].start < item.stop
      fail_on_overlapping_items(@schedule_items[index], item)
    end

    @schedule_items.insert(index, item)
  end

  def longest
    @schedule_items.map(&:duration).max
  end

  def contains?(schedule_item)
    @schedule_items.any? { |item| item == schedule_item }
  end

  private

  def fail_on_overlapping_items(item1, item2)
    fail ArgumentError.new "#{ item1 } (#{ item1.start } - #{ item1.stop }) and #{ item2 } (#{ item2.start } - #{ item2.stop }) cannot be in the same column"
  end
end
