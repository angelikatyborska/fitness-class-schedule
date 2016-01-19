class Admin::ReservationsController < Admin::AdminApplicationController
  expose(:reservations) do |default|
    default.order(:created_at)
  end

  expose(:reservation, attributes: :reservation_params)

  def new
    self.reservation = ScheduleItem.find(params[:schedule_item]).reservations.new
  end

  def create
    flash[:alert] = I18n.t('errors.generic') unless reservation.save
  end

  def update
    flash[:alert] = I18n.t('errors.generic') unless reservation.save
  end

  def destroy
    reservation.destroy
  end

  private

  def reservation_params
    params.require(:reservation).permit(:user_id, :schedule_item_id, :status)
  end
end
