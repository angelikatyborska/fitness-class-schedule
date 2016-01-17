class ScheduleItemsController < ApplicationController
  expose(:schedule_items)
  expose(:schedule_item)

  expose(:week_offset) { params[:week_offset].to_i || 0 }
  expose(:filter_header) { filter_header }
  expose(:filter_params) { filter_params }

  def index
    week = Time.zone.now.in_website_time_zone.beginning_of_week + week_offset.weeks

    self.schedule_items = ScheduleItem.week(week).hourly_time_frame(
      (Time.zone.now.in_website_time_zone.beginning_of_day + Configurable.day_start.hours).utc.hour,
      (Time.zone.now.in_website_time_zone.beginning_of_day + Configurable.day_end.hours).utc.hour
    )

    filter_params.each do |key, value|
      self.schedule_items = schedule_items.public_send(key, value)
    end
  end

  def focus
    week_offset = ((schedule_item.start.beginning_of_week - Time.zone.now.in_website_time_zone.beginning_of_week) / 1.week).round
    redirect_to action: :index, anchor: schedule_item.decorate.css_id, week_offset: week_offset
  end

  private

  def filter_params
    params.slice(:room, :trainer)
  end

  def filter_header
    header = filter_params.any? ? '' : ''

    filter_params.each_with_index.with_object(header) do |((key, value), index), header|
      name = t("#{ key }.name")
      globally_exposed_collection = eval(key.pluralize)

      header << ', ' unless index == 0
      header << "#{ name }: #{ globally_exposed_collection.find(value) }"
    end
  end
end