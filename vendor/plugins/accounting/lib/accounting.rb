# Copyright (C) 2011 Sergey Yanovich <ynvich@gmail.com>
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation; either version 3 of the
# License, or (at your option) any later version.
#
# Please see ./COPYING for details

Float.class_eval do
  def accounting_zero?
    self < 0.00009 and self > -0.00009
  end
  def accounting_round64
    if self < 0.0
      (self - 0.5).ceil
    else
      (self + 0.5).floor
    end
  end
  def accounting_norm
    (self * 100.0).accounting_round64 / 100.0
  end
  def accounting_negative?
    !self.accounting_zero? and self < 0.0
  end
end
