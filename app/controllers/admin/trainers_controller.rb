class Admin::TrainersController < Admin::AdminApplicationController
  expose(:trainers) do |default|
    default.order(:first_name)
  end

  expose(:trainer, attributes: :trainer_params)

  def create
    if trainer.save
      redirect_to(
        { action: :index, anchor: trainer.decorate.css_id },
        notice: I18n.t('shared.created', resource: I18n.t('trainer.name'))
      )
    else
      render :new
    end
  end

  def update
    if trainer.save
      redirect_to(
        { action: :index, anchor: trainer.decorate.css_id },
        notice: I18n.t('shared.updated', resource: I18n.t('trainer.name'))
      )
    else
      render :edit
    end
  end

  def destroy
    trainer.destroy
    flash.now[:notice] = I18n.t('shared.deleted', resource: I18n.t('trainer.name'))
  end

  private

  def trainer_params
    params.require(:trainer).permit(:first_name, :last_name, :description, :photo)
  end
end
