class Ability
  include CanCan::Ability

  def initialize(user)
    can :manage, :all if user && user.root?
    can :read, :all if user && !user.root?
  end
end
