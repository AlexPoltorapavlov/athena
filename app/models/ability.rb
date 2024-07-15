# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)

    user ||= User.new # guest user (not logged in)

    if user.is_admin?
      can :manage, :all
    else
      cannot :manage, :admins
      can :read, :all
      can :manage, User, id: user.id
    end
  end

end
