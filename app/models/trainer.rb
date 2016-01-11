class Trainer < ActiveRecord::Base
  has_many :schedule_items, dependent: :nullify

  validates :first_name, presence: true
  validates :description, presence: true

  include Occupiable

  def to_s
    first_name
  end
end