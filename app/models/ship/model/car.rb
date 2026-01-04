module Ship
  module Model::Car
    extend ActiveSupport::Concern

    included do
      attribute :brand, :string, comment: '车品牌'
      attribute :location, :string
      attribute :number, :string, comment: '车牌号'
      attribute :tel, :string, comment: '随车电话'
      attribute :detail, :json

      enum :carriage, {
        freight: 'freight',
        passenger: 'passenger'
      }
      enum :kind, {
        van: 'van',
        minibus: 'minibus',
        truck: 'truck'
      }

      belongs_to :organ, class_name: 'Org::Organ', optional: true
      belongs_to :user, class_name: 'Auth::User', optional: true # 车的实际拥有者

      has_many :car_drivers, dependent: :destroy_async
      has_many :drivers, through: :car_drivers

      has_one_attached :registration

      after_create_commit :ocr_later
    end

    def enter_url
      Rails.application.routes.url_for(controller: 'ship/me/cars', action: 'qrcode', id: self.id)
    end

    def qrcode_enter_url
      QrcodeUtil.data_url(enter_url)
    end

    def ocr_later
      CarOcrJob.perform_later(self)
    end

    def ocr
      r = TencentHelper.registration_ocr(registration.url)
      self.detail = r['FrontInfo']
      self.number = detail['PlateNo'] if detail.is_a?(Hash)
      self.save
      r
    end

    def for_update
      broadcast_action_to 'car_new', action: :update, target: 'car_update', partial: 'ship/my/cars/edit_form', locals: { car: self }
    end

  end
end
