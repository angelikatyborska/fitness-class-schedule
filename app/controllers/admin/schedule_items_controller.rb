class Admin::ScheduleItemsController < Admin::AdminApplicationController
  expose(:schedule_items) do |default|
    default.order(:start).includes([:room, :trainer])
  end

  expose(:schedule_item, attributes: :schedule_item_params)

  before_action :convert_start_to_website_time_zone, only: [:create, :update]

  def create
    if schedule_item.save
      redirect_to action: :index, anchor: schedule_item.decorate.css_id
    else
      render :new
    end
  end

  def update
    if schedule_item.save
      redirect_to action: :index, anchor: schedule_item.decorate.css_id
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
    params.require(:schedule_item).permit(:start, :duration, :trainer_id, :room_id, :fitness_class_id, :capacity)
  end

  def convert_start_to_website_time_zone
    if params[:schedule_item][:start]
      params[:schedule_item][:start] = Time.find_zone!(Configurable.time_zone).parse(params[:schedule_item][:start])
    end
  end
end
