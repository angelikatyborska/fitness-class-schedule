class Trainer < ActiveRecord::Base
  has_many :schedule_items, dependent: :destroy

  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :description, presence: true

  include Occupiable

  mount_uploader :photo, TrainerPhotoUploader

  def to_s
    "#{ first_name } #{ last_name[0] }."
  end
end