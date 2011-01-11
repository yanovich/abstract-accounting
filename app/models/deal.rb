class Deal < ActiveRecord::Base
  validates :tag, :rate, :presence => true
  belongs_to :entity
  belongs_to :give, :polymorphic => true
  belongs_to :take, :polymorphic => true
  has_many :states
  def state(day)
    states.where(:start => day).first
  end
end
