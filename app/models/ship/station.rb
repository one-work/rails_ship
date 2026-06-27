module Ship
  class Station < ApplicationRecord
    self.table_name = 'space_stations'
    include Model::Station
    include Space::Model::Station if defined? RailsSpace
  end
end
