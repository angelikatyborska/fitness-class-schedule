class Admin::RoomPhotosController < Admin::AdminApplicationController
  expose(:room)
  expose(:room_photos, ancestor: :room)
  expose(:room_photo, attributes: :room_photo_params)

  def new
    respond_to do |format|
      format.js
    end
  end

  def create
    unless room_photo.save
      flash[:alert] = t('room_photo.invalid')
    end

    redirect_to edit_admin_room_path(room_photo.room)
  end

  def destroy
    room_photo.destroy
    redirect_to edit_admin_room_path(room_photo.room)
  end

  private

  def room_photo_params
    params.require(:room_photo).permit(:room, :photo)
  end
end
