class ScheduleItemsController < ApplicationController
  expose(:rooms)
  expose(:room)
  expose(:week) { params[:week].nil? ? Time.zone.now : Time.parse(params[:week])}
  expose(:schedule_items, ancestor: :room) do |default|
    default.order(:start)
  end

  expose(:schedule_item)
  expose(:schedule_items_by_day) do
    weekdays = {}

    7.times do |n|
      weekdays[week.beginning_of_week + n.days] = []
    end

    schedule_items.map do |item|
      weekdays[item.start.beginning_of_day] << item
    end

    weekdays
  end

  def index
    self.schedule_items = room.schedule_items.week(week).order(:start)
  end

  def show
  end
end