class Asset < ActiveRecord::Base
  validates_presence_of :tag
  validates_uniqueness_of :tag
  has_many :deal_gives, :class_name => "Deal", :as => :give
  has_many :deal_takes, :class_name => "Deal", :as => :take
end

class Money < ActiveRecord::Base
  validates_presence_of :num_code
  validates_presence_of :alpha_code
  validates_uniqueness_of :num_code
  validates_uniqueness_of :alpha_code
  has_many :deal_gives, :class_name => "Deal", :as => :give
  has_many :deal_takes, :class_name => "Deal", :as => :take
end
