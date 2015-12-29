class RoomsController < ApplicationController
  expose(:schedule_items) do |default|
    default.order(:start).includes([:room, :trainer])
  end

  def index
    self.schedule_items = ScheduleItem.week(week).order(:start)
  end
end