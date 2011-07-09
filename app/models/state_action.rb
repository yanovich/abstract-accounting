# Copyright (C) 2011 Sergey Yanovich <ynvich@gmail.com>
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation; either version 3 of the
# License, or (at your option) any later version.
#
# Please see ./COPYING for details

module StateAction
  PASSIVE = "passive"
  ACTIVE = "active"

  def resource
    return nil if self.deal.nil?
    self.side == ACTIVE ? self.deal.take : self.deal.give
  end
end
