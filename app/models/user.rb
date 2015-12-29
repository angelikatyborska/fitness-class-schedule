class User < ActiveRecord::Base
  rolify
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :reservations, dependent: :destroy
  has_many :schedule_items, through: :reservations

  def admin?
    has_role?(:admin)
  end
end
