class ScheduleItemsController < ApplicationController
  expose(:rooms)
  expose(:room)
  expose(:schedule_items, ancestor: :room) do |default|
    default.order(:start)
  end

  expose(:schedule_item)

  def index
    self.schedule_items = room.schedule_items.week(week).order(:start)
  end

  def show
  end
end