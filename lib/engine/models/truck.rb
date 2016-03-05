class Truck < ActiveRecord::Base
  @@matchcache = {}
  include Like

  has_many :patterns, class_name:"TruckPattern"

  validates :truck, :city, presence: true
  validates :truck, uniqueness: {scope: :city}

  scope :like, -> n { where id:select{|x| x =~ n }.collect(&:id) }
  scope :match, -> args {
    @@matchcache[args] ||= Truck.where(city:args[:city]).like(args[:truck]).first
    @@matchcache[args] || Truck.new(args.slice(:city, :truck, :source))
  }

  def name
    truck
  end
end
