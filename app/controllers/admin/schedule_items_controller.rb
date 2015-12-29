class Admin::ScheduleItemsController < Admin::AdminApplicationController
  expose(:schedule_items) do |default|
    default.order(:start).includes([:room, :trainer])
  end

  expose(:schedule_item, attributes: :schedule_item_params)

  def update
    if schedule_item.save
      redirect_to admin_schedule_item_path(schedule_item), notice: I18n.t('shared.updated', resource: I18n.t('schedule_item.name'))
    else
      render :edit
    end
  end

  def destroy
    schedule_item.destroy
    redirect_to admin_schedule_items_path, notice: I18n.t('shared.deleted', resource: I18n.t('schedule_item.name'))
  end

  private

  def schedule_item_params
    params.require(:schedule_item).permit(:start, :duration, :trainer, :room, :activity)
  end
end
