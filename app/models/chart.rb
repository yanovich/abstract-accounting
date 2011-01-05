class Chart < ActiveRecord::Base
  belongs_to :money
  validates_presence_of :money
  validates_uniqueness_of :money_id
end
