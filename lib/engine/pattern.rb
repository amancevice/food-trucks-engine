class Pattern < ActiveRecord::Base
  def exp
    Regexp.new value
  end
end

class PlacePattern < Pattern
  belongs_to :pattern
end

class TruckPattern < Pattern
  belongs_to :truck
end
