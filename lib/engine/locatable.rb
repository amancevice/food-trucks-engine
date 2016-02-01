module Locatable
  def nearby? lat:nil, lng:nil, max:0.05
    unless lat.nil? || lng.nil? || latitude.nil? || longitude.nil?
      r    = 6371.0
      dlat = radians lat - latitude
      dlng = radians lng - longitude
      a    = Math::sin(dlat/2.0) ** 2 +
             Math::cos(radians latitude) *
             Math::cos(radians lat) *
             Math::sin(dlng/2.0) ** 2
      c    = 2.0 * Math::atan2(Math::sqrt(a), Math::sqrt(1.0 - a))

      r * c <= max
    end
  end

  private

  def radians degrees
    degrees * Math::PI/180.0
  end
end
