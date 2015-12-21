class ScheduleItemsController < ApplicationController
  expose(:week) { params[:week].nil? ? Time.zone.now : Time.parse(params[:week])}

  expose(:schedule_items) do |default|
    default.week(week).order(:start)
  end

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
  end
end