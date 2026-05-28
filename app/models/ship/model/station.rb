module Ship
  module Model::Station
    extend ActiveSupport::Concern

    included do
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

      has_many :line_stations, dependent: :destroy_async
      has_many :lines, through: :line_stations
      has_many :shipments, through: :lines
      has_many :addresses

      after_save_commit :geo_later, if: -> { saved_change_to_lat? || saved_change_to_lng? }
      after_save_commit :sync_to_line, if: -> { saved_change_to_name? }
    end

    def sync_to_line
      lines.each(&:sync_names_to_line)
    end

    def geo_later
      LocationGeoJob.perform_later(self)
    end

    # todo 依赖 rails profiled
    def geo
      result = QqMapHelper.geocoder(lat: lat, lng: lng)
      r = result['address_component']
      area = Area.sure_find [r['province'], r['city'], r['district']]
      self.area = area
      self.save
      result
    end

  end
end

