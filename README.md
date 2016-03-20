# EaterAtlas Engine

ActiveRecord engine for food Trucks location data.


## Engine

The engine defines two models, `Place`, `Truck`, and a third class, `Pattern`, which has a polymorphic many-to-one relation with the former two. Both `Place` & `Truck` define a `match` method that can be used to find a close likeness given a hash of attributes.


### Match Place

A `Place` can be matched by calling `Place.match` with a hash of `:city`, `:name`, `:source`, `:latitude`, & `:latitude`, and an optional `:dist`. A hash is matched to a `Place` first by name, then by proximity 


## Server


## Client


## Sources
