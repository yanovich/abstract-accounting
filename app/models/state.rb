class State < ActiveRecord::Base
  validates :amount, :start, :side, :deal, :presence => true
  validates_inclusion_of :side, :in => ["passive", "active"] #[1, 0]
  belongs_to :deal
  
  after_initialize :do_init
  
  def resource
    return nil? unless self.deal
    return self.deal.take if self.side == "passive"
    self.deal.give
  end
  
  def apply_fact(aFact)
    return false if self.deal.nil?
    return false if aFact.nil?
    true if set_fact_side(aFact) and update_time(aFact.day)
  end
  
  def value
    return @value if self.deal.nil?
    if self.side == "passive"
      return self.amount * @debit_rate if @debit_rate
    else
      return self.amount * @credit_rate if @credit_rate
    end
    return @value
  end
  
  private
  def do_init
    self.side ||= "active"
    self.amount ||= 0.0
    @value = 0.0
    @credit_rate = 0.0
    @debit_rate = 0.0
    @rate = 1.0
    @diff0 = 0.0
    @diff1 = 0.0
  end
  
  def set_fact_side(aFact)
    return false if aFact.nil?
    @fact_side =
      if self.deal == aFact.from
        "active"
      else
        "passive"
      end
    @old_amount = self.amount
    @old_value = self.value
    
    @rate = self.deal.rate
    if self.side == @fact_side
      @diff0 = aFact.amount
      self.amount -= @diff0
    else
      @diff1 = aFact.amount *
        if self.side == "passive"
          @rate
        else
          1/@rate
        end
      self.amount += @diff1
    end
    
    if self.amount != 0.0 && self.amount < 0.0
      self.side =
        if self.side == "passive"
          "active"
        else
          "passive"
        end
      self.amount = self.amount * -1 *
        if self.side == "passive"
          @rate
        else
          1/@rate
        end
      @diff0 = @old_amount
      @diff1 = self.amount
      @old_value = -@old_value
    end
    true
  end
  
  def update_time(aTime)
    self.start = aTime
    true
  end
end
