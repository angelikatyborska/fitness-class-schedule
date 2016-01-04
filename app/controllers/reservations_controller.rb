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
    if reservation.save
      redirect_to user_reservations_path(user), notice: I18n.t('reservation.created')
    else
      redirect_to user_reservations_path(user), alert: I18n.t('reservation.not_created')
    end
  end

  def destroy
    reservation.destroy
    redirect_to user_reservations_path(user), notice: I18n.t('reservation.deleted')
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