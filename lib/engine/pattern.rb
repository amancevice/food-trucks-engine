class Pattern < ActiveRecord::Base
  def =~ name
    Regexp.new(value) =~ name
  end
end

class PlacePattern < Pattern
  belongs_to :pattern
end

class TruckPattern < Pattern
  belongs_to :truck
end
