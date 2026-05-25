module Ship
  module Ext::User
    extend ActiveSupport::Concern

    included do
      has_one :driver, class_name: 'Ship::Driver'

      has_many :addresses, class_name: 'Ship::Address'
      has_many :cars, class_name: 'Ship::Car'
      has_many :ways, class_name: 'Ship::Way', dependent: :destroy

      has_many :ship_favorites, class_name: 'Ship::Favorite'
      has_many :drivers, class_name: 'Ship::Driver', through: :favorites
      has_many :boxes, class_name: 'Ship::Box', foreign_key: :held_user_id
      has_many :packages, class_name: 'Ship::Package'
      has_many :box_holds, class_name: 'Ship::BoxHold'
      has_many :box_sells, class_name: 'Ship::BoxSell'
    end

  end
end
