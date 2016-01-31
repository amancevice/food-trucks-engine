module Engine
  class Migration < ActiveRecord::Migration
    def change
      create_table :places do |t|
        t.float  :latitude
        t.float  :longitude
        t.string :city
        t.string :cross
        t.string :main
        t.string :name
        t.string :neighborhood
        t.string :number
        t.string :source
        t.string :street
        t.string :type
      end

      create_table :trucks do |t|
        t.string :city
        t.string :name
        t.string :site
        t.string :source
      end

      create_table :patterns do |t|
        t.belongs_to :place
        t.belongs_to :truck
        t.string     :type
        t.string     :value
      end
    end
  end
end
