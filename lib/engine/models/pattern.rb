class Pattern < ActiveRecord::Base
  def =~ name
    name =~ exp
  end

  def exp
    Regexp.new value
  end
end

class PlacePattern < Pattern
  belongs_to :pattern
  validates :value, uniqueness: {scope: :place_id}
end

class TruckPattern < Pattern
  belongs_to :truck
  validates :value, uniqueness: {scope: :truck_id}
end
