class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable,
         authentication_keys: [:login]
        #  :validatable


  attr_writer :login

  # validates :email, presence: false


  def login
    @login || self.telegram_link || self.email
  end

  def is_admin?
    role == 'admin'
  end

  def is_user?
    role == 'user'
  end

  def self.find_for_database_authentication(warden_conditions)
    conditions = warden_conditions.dup
    if (login = conditions.delete(:login))
      where(conditions.to_h).where(["lower(telegram_link) = :value OR lower(email) = :value", { :value => login.downcase }]).first
    elsif conditions.has_key?(:telegram_link) || conditions.has_key?(:email)
      where(conditions.to_h).first
    end
  end

end
