class Admin::ScheduleItemsController < Admin::AdminApplicationController
  expose(:schedule_items) do |default|
    default.order(:start).includes([:room, :trainer])
  end

  expose(:schedule_item)

  def destroy
     schedule_item.destroy
     redirect_to admin_schedule_items_path, notice: I18n.t('shared.deleted', resource: I18n.t('schedule_item.name'))
  end
end
