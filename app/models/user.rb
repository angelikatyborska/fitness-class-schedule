class User < ActiveRecord::Base
  rolify
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :confirmable

  has_many :reservations, dependent: :destroy
  has_many :schedule_items, through: :reservations

  validates :first_name, presence: true
  validates :last_name, presence: true

  default_scope { includes(:reservations)}

  def admin?
    has_role?(:admin)
  end

  def reservation_for(schedule_item)
    reservations.find { |reservation| reservation.schedule_item == schedule_item }
  end

  def reservation_for?(schedule_item)
    !reservation_for(schedule_item).nil?
  end
end
