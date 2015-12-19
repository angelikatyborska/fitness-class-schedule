class ScheduleItemsController < ApplicationController
  expose(:schedule_items) do
    ScheduleItem.week(@week).order(:start)
  end

  def index
    if params[:week]
      @week = DateTime.parse(params[:week])
    else
      @week = DateTime.now
    end
  end
end