module Ship
  module Ext::Item
    extend ActiveSupport::Concern

    included do
      has_many :packageds, class_name: 'Ship::Packaged', dependent: :destroy_async
      has_many :packages, class_name: 'Ship::Package', through: :packageds

      belongs_to :box_hold, ->(o) { where(organ_id: o.organ_id, member_id: o.member_id, box_specification_id: o.good.box_specification_id) }, class_name: 'Ship::BoxHold', foreign_key: :user_id, primary_key: :user_id, optional: true
      belongs_to :box_proxy_buy, ->(o) { where(price: o.single_price) }, class_name: 'Ship::BoxProxyBuy', foreign_key: :good_id, primary_key: :box_host_id, optional: true

      after_save :init_box_hold, if: -> { good.respond_to?(:box_specification_id) && saved_change_to_status? && ['deliverable'].include?(status) }
      after_save :init_box_proxy_buy, if: -> { good_type == 'Ship::BoxHost' && saved_change_to_status? && ['deliverable'].include?(status) }
      after_save :reset_proxy_count, if: -> { good_type == 'Ship::BoxHost' && saved_change_to_rest_number? }
      after_destroy :reset_proxy_count, if: -> { good_type == 'Ship::BoxHost' }
    end

    def init_box_hold
      box_hold || build_box_hold
      box_hold.save
    end

    def init_box_proxy_buy
      box_proxy_buy || build_box_proxy_buy
      box_proxy_buy.save
    end

    def reset_proxy_count
      box_proxy_buy&.reset_buyable_count!
    end

  end
end
