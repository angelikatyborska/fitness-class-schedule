class ScheduleItemsController < ApplicationController
  expose(:schedule_items) do
    ScheduleItem.week(@week).order(:start)
  end

  expose(:schedule_items_by_day) do
    schedule_items.map.with_object({}) do |item, weekdays|
      weekdays[item.start.beginning_of_day] ||= []
      weekdays[item.start.beginning_of_day] << item
    end
  end

  def index
    if params[:week]
      @week = DateTime.parse(params[:week])
    else
      @week = DateTime.now
    end
  end
end