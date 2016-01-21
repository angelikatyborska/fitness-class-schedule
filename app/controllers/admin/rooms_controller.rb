class Admin::RoomsController < Admin::AdminApplicationController
  expose(:rooms) do |default|
    default.order(:name).includes(:room_photos)
  end

  expose(:room, attributes: :room_params)

  def create
    if room.save
      redirect_to action: :index, anchor: room.decorate.css_id
    else
      render :new
    end
  end

  def update
    if room.save
      redirect_to action: :index, anchor: room.decorate.css_id
    else
      render :edit
    end
  end

  def destroy
    room.destroy
    redirect_to admin_rooms_path, notice: I18n.t('shared.deleted', resource: I18n.t('room.name'))
  end

  private

  def room_params
    params.require(:room).permit(:name, :description)
  end
end
