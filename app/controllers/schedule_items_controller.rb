class ScheduleItemsController < ApplicationController
  expose(:rooms)
  expose(:room)
  expose(:schedule_items) do
    schedule_items = ScheduleItem.all

    filter_params.each do |key, value|
      schedule_items = schedule_items.public_send(key, value)
    end

    schedule_items
  end

  expose(:schedule_item)
  expose(:week_offset) { params[:week_offset].to_i || 0 }
  expose(:header) { filter_header }

  def index
    respond_to do |format|
      format.html
      format.js { render :reload_index }
    end
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