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
end
