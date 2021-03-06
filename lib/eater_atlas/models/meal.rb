module Meal
  class MealEnum < String
    attr_reader :hours
    def initialize str, hours
      super str
      @hours = hours
    end
  end

  BREAKFAST  = Meal::MealEnum.new "Breakfast",  (5...11).to_a
  LUNCH      = Meal::MealEnum.new "Lunch",      (11...16).to_a
  DINNER     = Meal::MealEnum.new "Dinner",     (16...21).to_a
  LATE_NIGHT = Meal::MealEnum.new "Late Night", [(21...24), (0...5)].map(&:to_a).flatten

  def self.all
    [BREAKFAST, LUNCH, DINNER, LATE_NIGHT]
  end

  def self.parse weekday
    Meal.all.select{|x| x == weekday }.first
  end

  def self.between args
    start = Time.parse(args[:start]).in_time_zone args[:timezone]
    stop  = Time.parse(args[:stop]).in_time_zone args[:timezone]
    range = start.to_i..stop.to_i
    hours = range.step(1.hour).map{|x| Time.at(x).in_time_zone(args[:timezone]).hour }

    breakfast  = (5...11).to_a
    lunch      = (11...16).to_a
    dinner     = (16...21).to_a
    late_night = [(21...24), (0...5)].map(&:to_a).flatten

    meals = []
    meals << BREAKFAST  if (breakfast & hours).any?
    meals << LUNCH      if (lunch & hours).any?
    meals << DINNER     if (dinner & hours).any?
    meals << LATE_NIGHT if (late_night & hours).any?

    meals
  end
end
