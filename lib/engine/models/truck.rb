class Truck < ActiveRecord::Base
  include Like

  has_many :patterns, class_name:"TruckPattern"

  validates :truck, :city, presence: true
  validates :truck, uniqueness: {scope: :city}

  scope :like, -> n { where id:select{|x| x =~ n }.collect(&:id) }
  scope :match, -> args {
    truck   = Truck.where(city:args[:city]).like(args[:truck]).first
    truck ||= Truck.new args.slice(:city, :truck, :source)
  }

  def name
    truck
  end
end
