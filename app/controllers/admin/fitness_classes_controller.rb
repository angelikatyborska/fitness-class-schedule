class Admin::FitnessClassesController < Admin::AdminApplicationController
  expose(:fitness_classes) do |default|
    default.order(:name)
  end

  expose(:fitness_class, attributes: :fitness_class_params)

  def create
    if fitness_class.save
      redirect_to(
        { action: :index, anchor: fitness_class.decorate.css_id },
        notice: I18n.t('shared.created', resource: I18n.t('fitness_class.name'))
      )
    else
      render :new
    end
  end

  def update
    if fitness_class.save
      redirect_to(
        { action: :index, anchor: fitness_class.decorate.css_id },
        notice: I18n.t('shared.updated', resource: I18n.t('fitness_class.name'))
      )
    else
      render :edit
    end
  end

  def destroy
    fitness_class.destroy
    flash.now[:notice] = I18n.t('shared.deleted', resource: I18n.t('fitness_class.name'))
  end

  private

  def fitness_class_params
    params.require(:fitness_class).permit(:name, :description, :color)
  end

  def convert_start_to_website_time_zone
    if params[:fitness_class][:start]
      params[:fitness_class][:start] = Time.find_zone!(SiteSettings.instance.time_zone).parse(params[:fitness_class][:start])
    end
  end
end
