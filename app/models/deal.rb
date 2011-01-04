class Deal < ActiveRecord::Base
  validates_presence_of :tag
  validates_presence_of :rate
  belongs_to :entity
end
