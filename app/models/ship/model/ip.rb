module Ship
  module Model::Ip
    extend ActiveSupport::Concern

    included do
      attribute :ip_address, :string, index: true
      attribute :ip_city, :string
      attribute :lat, :decimal, precision: 10, scale: 8
      attribute :lng, :decimal, precision: 11, scale: 8
      attribute :code, :string

      has_one :area, primary_key: :code, foreign_key: :code
      has_one :named_area, class_name: 'Area', primary_key: :ip_city, foreign_key: :full

      before_create :get_ip_detail
    end

    def get_ip_detail
      area = QqMapHelper.ip ip_address
      self.lat = area.dig('location', 'lat')
      self.lng = area.dig('location', 'lng')
      self.ip_city = area.dig('ad_info', 'city')
      self.code = area.dig('ad_info', 'adcode')
    end

  end
end
