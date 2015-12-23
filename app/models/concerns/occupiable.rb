module Occupiable
  def occupied?(from, to, options = {})
    except = options.fetch(:except, nil)
    schedule_items.any? do |item|
      item !=  except && ((item.start >= from && item.start <= to) || (item.stop >= from && item.stop <= to))
    end
  end
end