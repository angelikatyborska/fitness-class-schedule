class ReservationsController < ApplicationController
  expose(:user)
  expose(:reservations, ancestor: :user) do |default|
    default.includes(:schedule_item)
  end
  expose(:reservation, attributes: :reservation_params)

  before_action :authorize_user!

  def index
  end

  def create
    respond_to do |format|
      if reservation.save
        flash[:notice] = I18n.t('reservation.created')

        format.html { redirect_to user_reservations_path(user) }
        format.js { render inline: 'location.reload();' }
      else
        flash[:alert] = I18n.t('reservation.not_created')
        format.html { redirect_to user_reservations_path(user) }
        format.js { render inline: 'location.reload();' }
      end
    end
  end

  def destroy
    reservation.destroy
    respond_to do |format|
      flash[:notice] = I18n.t('reservation.deleted')
      format.html { redirect_to user_reservations_path(user) }
      format.js { render inline: 'location.reload();' }
    end
  end

  private

  def reservation_params
    params.require(:reservation).permit(:user_id, :schedule_item_id)
  end

  def authorize_user!
    return true if user_signed_in? && reservation.user && current_user == reservation.user
    redirect_to new_user_session_path
  end
end