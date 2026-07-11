module Ship
  module Model::ShipmentLog
    extend ActiveSupport::Concern

    included do
      attribute :expected_leave_at, :datetime
      attribute :left_at, :datetime
      attribute :arrived_at, :datetime
      attribute :prepared_at, :datetime

      belongs_to :shipment
      belongs_to :station

      has_many :shipment_items, primary_key: :shipment_id, foreign_key: :shipment_id
      has_many :current_shipment_items, class_name: 'ShipmentItem', primary_key: [:station_id, :shipment_id], foreign_key: [:station_id, :shipment_id]
      has_many :payment_orders, -> { where(kind: 'item_amount') }, through: :current_shipment_items

      after_save :change_state_to_left, if: -> { left_at && saved_change_to_left_at? }
      after_save :change_state_to_arrived, if: -> { arrived_at && saved_change_to_arrived_at? }
    end

    def change_state_to_left
      shipment.left_at = left_at
      shipment.change_state_to_left!
    end

    def change_state_to_arrived
      shipment.arrived_at = arrived_at
      shipment.change_state_to_arrived!
    end

    def expected_arrive_at
      (arrived_at || expected_leave_at) + shipment.expected_minutes
    end

  end
end

