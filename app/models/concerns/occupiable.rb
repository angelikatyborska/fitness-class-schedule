module Occupiable
  def occupied?(from, to)
    schedule_items.any? do |item|
      (item.start >= from && item.start <= to) || (item.stop >= from && item.stop <= to)
    end
  end
end