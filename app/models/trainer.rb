class Trainer < ActiveRecord::Base
  has_many :schedule_items

  validates :first_name, presence: true
  validates :description, presence: true
end