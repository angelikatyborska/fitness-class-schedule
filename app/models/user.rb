class User < ActiveRecord::Base
  rolify
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :reservations, dependent: :destroy
  has_many :schedule_items, through: :reservations

  def admin?
    has_role?(:admin)
  end

  def reservation_for(schedule_item)
    reservations.find_by(schedule_item: schedule_item)
  end

  def reservation_for?(schedule_item)
    !reservation_for(schedule_item).nil?
  end
end
