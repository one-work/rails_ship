module Ship
  module Model::Packaged
    extend ActiveSupport::Concern

    included do
      attribute :item_status, :string

      belongs_to :item, class_name: 'Trade::Item'
      belongs_to :good, optional: true, polymorphic: true
      belongs_to :package, inverse_of: :packageds, counter_cache: true

      before_validation :compute_item, if: -> { good_id.present? }
      after_create :update_status
      after_save :sync_item_status, if: -> { saved_change_to_item_id? }
      after_destroy :revert_status
    end

    def compute_item
      if good_type == 'Factory::ProductionItem'
        self.item = (package.address || package.user).items.packable.find_by(good_type: 'Factory::Production', good_id: good.production_id)
      elsif good_type == 'Ship::Box'
        self.item = (package.address || package.user).items.packable.find_by(good_type: 'Ship::BoxHost', good_id: good.box_host.id)
      end
    end

    def update_status
      self.item.update status: 'packaged'
    end

    def sync_item_status
      self.item_status = item.status
      self.save
    end

    def revert_status
      self.item.update status: self.item_status
    end

  end
end
