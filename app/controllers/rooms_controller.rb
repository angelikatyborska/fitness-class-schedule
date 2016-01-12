class RoomsController < ApplicationController
  expose(:schedule_items) do |default|
    default.order(:start).includes([:room, :trainer])
  end

  expose(:room)

  expose(:week_offset) { params[:week_offset].to_i || 0 }

  def next_week
    respond_to do |format|
      format.js { render 'reload_index' }
    end
  end

  def prev_week
    respond_to do |format|
      format.js { render 'reload_index' }
    end
  end
end