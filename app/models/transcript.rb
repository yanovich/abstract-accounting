# Copyright (C) 2011 Sergey Yanovich <ynvich@gmail.com>
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation; either version 3 of the
# License, or (at your option) any later version.
#
# Please see ./COPYING for details

class Transcript
  def initialize(deal, start, stop)
    @deal = deal
    @start = start
    @stop = stop
  end
  attr_reader :deal, :start, :stop
end
