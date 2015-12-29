class RoomsController < ApplicationController
  expose(:schedule_items)

  def index
    self.schedule_items = ScheduleItem.week(week).order(:start)
  end
end