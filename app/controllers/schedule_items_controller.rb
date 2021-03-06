class ScheduleItemsController < ApplicationController
  add_flash_types :focus

  expose(:current_user) do
    if devise_current_user.nil?
      nil
    else
      User.includes(reservations: [:schedule_item]).find(devise_current_user.id)
    end
  end

  expose(:rooms)
  expose(:trainers)

  expose(:schedule_items) do |default|
    default.order(:start).includes([:fitness_class, :room])
  end
  expose(:schedule_item, attributes: :schedule_item_params)

  expose(:week_offset) { params[:week_offset].to_i || 0 }
  expose(:filter_params) { filter_params }

  def index
    week = Time.zone.now.in_website_time_zone.beginning_of_week + week_offset.weeks

    if SiteSettings.instance.day_start > SiteSettings.instance.day_end
      self.schedule_items = schedule_items.none
    else
      self.schedule_items = self.schedule_items.week(week).hourly_time_frame(
        (Time.zone.now.in_website_time_zone.beginning_of_day + SiteSettings.instance.day_start.hours).utc.hour,
        (Time.zone.now.in_website_time_zone.beginning_of_day + SiteSettings.instance.day_end.hours).utc.hour
      )
    end

    filter_params.each do |key, value|
      self.schedule_items = schedule_items.public_send(key, value)
    end
  end

  def focus
    flash[:focus] = schedule_item.decorate.css_id
    week_offset = ((schedule_item.start.in_website_time_zone.beginning_of_week - Time.zone.now.in_website_time_zone.beginning_of_week) / 1.week).round
    redirect_to action: :index, week_offset: week_offset
  end

  private

  def schedule_item_params
    params.require(:schedule_item)
  end

  def filter_params
    params.slice(:room, :trainer)
  end
end