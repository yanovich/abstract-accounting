class FactValidator
  def validate(record)
    record.errors[:base] << "bad resource" unless
      record.resource == record.from.take \
        and record.resource == record.to.give
  end
end

class Fact < ActiveRecord::Base
  validates :day, :amount, :resource, :from, :to, :presence => true
  validates_with FactValidator
  belongs_to :resource, :polymorphic => true
  belongs_to :from, :class_name => "Deal", :foreign_key => "from_deal_id"
  belongs_to :to, :class_name => "Deal", :foreign_key => "to_deal_id"

  before_save :do_save

  private
  def do_save
    return false unless from.states.count <= 1 and to.states.count <= 1
    return false unless init_state(self.from.states.first, self.from)
    return false unless init_state(self.to.states.first, self.to)
  end
  
  def init_state(aState, aDeal)
    return false if aDeal.nil?
    state =
      if aState.nil?
        State.new
      else
        aState
      end
    state.deal = aDeal
    state.apply_fact(self)
    state.save!
  end
end

