class Admin::UsersController < Admin::AdminApplicationController
  expose(:users) do |default|
    default.order(:last_name).includes(:reservations)
  end

  expose(:user, attributes: :user_params)

  def show
    self.user = User.includes(reservations: [schedule_item: [:fitness_class, :room, :reservations]]).find(params[:id])
  end

  def update
    if user.save
      redirect_to(
        { action: :index, anchor: user.decorate.css_id},
        notice: I18n.t('shared.updated', resource: I18n.t('user.name'))
      )
    else
      render :edit
    end
  end

  def destroy
    user.destroy
    redirect_to admin_users_path, notice: I18n.t('shared.deleted', resource: I18n.t('user.name'))
  end

  private

  def user_params
    params.require(:user).permit(:first_name, :last_name, :email)
  end
end
