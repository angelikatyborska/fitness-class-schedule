class Admin::ScheduleItemsController < Admin::AdminApplicationController
  expose(:rooms)
  expose(:trainers)

  expose(:schedule_items) do |default|
    default.order(:start).includes([:fitness_class, :room, :trainer])
  end

  expose(:schedule_item, attributes: :schedule_item_params)

  before_action :convert_start_to_website_time_zone, only: [:create, :update]

  def show
    self.schedule_item = ScheduleItem.includes([:fitness_class, reservations: [user: [:reservations]]]).find(params[:id])
  end

  def create
    if schedule_item.save
      redirect_to focus_schedule_item_path(schedule_item)
    else
      render :new
    end
  end

  def update
    if schedule_item.save
      redirect_to focus_schedule_item_path(schedule_item)
    else
      render :edit
    end
  end

  def destroy
    schedule_item.destroy
    flash.now[:notice] = I18n.t('shared.deleted', resource: I18n.t('schedule_item.name'))
  end

  private

  def schedule_item_params
    params.require(:schedule_item).permit(:start, :duration, :trainer_id, :room_id, :fitness_class_id, :capacity)
  end

  def convert_start_to_website_time_zone
    if params[:schedule_item][:start]
      params[:schedule_item][:start] = Time.find_zone!(SiteSettings.instance.time_zone).parse(params[:schedule_item][:start])
    end
  end
end
