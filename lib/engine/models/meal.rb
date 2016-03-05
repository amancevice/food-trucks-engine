module Meal
  BREAKFAST  = "Breakfast"
  LUNCH      = "Lunch"
  DINNER     = "Dinner"
  LATE_NIGHT = "Late Night"

  def self.between args
    start = Time.parse(args[:start]).in_time_zone args[:timezone]
    stop  = Time.parse(args[:stop]).in_time_zone args[:timezone]
    range = start.to_i..stop.to_i
    hours = range.step(1.hour).map{|x| Time.at(x).in_time_zone(args[:timezone]).hour }

    breakfast  = (5...11).to_a
    lunch      = (11...16).to_a
    dinner     = (16...20).to_a
    late_night = [(20...24), (0...5)].map(&:to_a).flatten

    meals = []
    meals << BREAKFAST  if (breakfast & hours).any?
    meals << LUNCH      if (lunch & hours).any?
    meals << DINNER     if (dinner & hours).any?
    meals << LATE_NIGHT if (late_night & hours).any?

    meals
  end
end
