module Ship
  module Model::Location
    extend ActiveSupport::Concern

    included do
      attribute :name, :string
      attribute :position, :integer
      attribute :poiname, :string
      attribute :poiaddress, :string
      attribute :cityname, :string
      attribute :lat, :decimal, precision: 10, scale: 8
      attribute :lng, :decimal, precision: 11, scale: 8
      if ['PostgreSQL', 'PostGIS'].include?(connection.adapter_name)
        attribute :coordinate, :point
      else
        attribute :coordinate, :string
      end

      belongs_to :area, optional: true
      has_taxons :area

      belongs_to :way, counter_cache: true
      belongs_to :station, optional: true

      positioned on: [:way_id]

      after_save_commit :sync_names_to_way, if: -> { saved_change_to_position? }
    end

    def position_text
      if way.new_record?
        count = way.locations.size
      else
        count = way.locations_count
      end

      if position.to_i == 0
        '起点'
      elsif position.to_i >= count
        '终点'
      else
        "途经点#{position}"
      end
    end

    def sync_names_to_way
      way.sync_names_from_locations
    end

    def next_item
      line.line_stations.find(&->(i){ i.position > position }) || line.line_stations.find(&->(i){ i.position == position })
    end

    def prev_item
      line.line_stations.find(&->(i){ i.position < position }) || line.line_stations.find(&->(i){ i.position == position })
    end

  end
end
