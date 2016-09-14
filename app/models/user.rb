class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  def name
    e = email
    e[0..e.index('@')-1].titleize
  end

  def active_for_authentication?
    super && (self.admin || self.staff)
  end
end
