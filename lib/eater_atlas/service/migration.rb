module EaterAtlas
  class Migration < ActiveRecord::Migration[5.1]
    def change
      create_table :places do |t|
        t.float  :latitude
        t.float  :longitude
        t.string :city
        t.string :cross
        t.string :main
        t.string :place
        t.string :geoname
        t.string :neighborhood
        t.string :number
        t.string :source
        t.string :street
        t.string :timezone
        t.string :type
      end

      add_index :places, [:latitude, :longitude]

      create_table :trucks do |t|
        t.string :city
        t.string :truck
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
