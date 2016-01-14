class RoomsController < ApplicationController
  expose(:rooms) do |default|
    default.order(:name)
  end

  expose(:room)

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