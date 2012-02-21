require "#{Rails.root}/lib/accounting/accounting.rb"

Float.class_eval { include Accounting }