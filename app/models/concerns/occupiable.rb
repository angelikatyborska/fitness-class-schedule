module Occupiable
  def occupied?(from, to, options = {})
    except = options.fetch(:except, nil)
    schedule_items.any? do |item|
      item !=  except && item.going_on_between?(from, to)
    end
  end
end