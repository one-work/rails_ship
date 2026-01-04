module Ship
  module Model::Box
    extend ActiveSupport::Concern

    included do
      attribute :code, :string
      attribute :shipment_items_count, :integer, default: 0
      attribute :box_logs_count, :integer, default: 0

      enum :status, {
        born: 'born',
        free: 'free',
        using: 'using'
      }, default: 'born', prefix: true
      enum :state, {
        grid_in: 'grid_in',
        grid_out: 'grid_out',
        loaded: 'loaded',
        unloaded: 'unloaded'
      }, prefix: true

      belongs_to :organ, class_name: 'Org::Organ', optional: true

      belongs_to :box_specification, counter_cache: true
      belongs_to :box_host, ->(o) { where(organ_id: o.organ_id) }, foreign_key: :box_specification_id, primary_key: :box_specification_id, optional: true
      belongs_to :box_hold, ->(o) { where(organ_id: o.organ_id, user_id: o.held_user_id) }, foreign_key: :box_specification_id, primary_key: :box_specification_id, optional: true

      has_many :packages, dependent: :nullify
      has_one :shipment_item, -> { order(id: :desc) }
      has_many :shipment_items
      has_many :shipments, through: :shipment_items
      has_many :box_logs
      has_many :using_box_logs, -> { where(boxed_out_at: nil) }, class_name: 'BoxLog'

      before_validation :init_code, if: -> { code.blank? }
      before_validation :init_box_host, if: -> { organ_id.present? && organ_id_changed? }
      after_save :increment_boxes_count, if: -> { organ_id.present? && saved_change_to_organ_id? }
      after_save :decrement_boxes_count, if: -> { organ_id.blank? && saved_change_to_organ_id? }
      after_destroy :decrement_boxes_count
    end

    def init_code
      self.code = UidUtil.usec_uuid('BOX')
    end

    def init_box_host
      box_host || build_box_host
    end

    def increment_boxes_count
      box_host&.increment! :boxes_count
      box_host&.increment! :tradable_count unless held
    end

    def decrement_boxes_count
      box_host&.decrement! :boxes_count
      box_host&.decrement! :tradable_count unless held
    end

    def to_pdf
      pdf = BasePdf.new(width: 78.mm, height: 40.mm)
      pdf_content(pdf)
      pdf
    end

    def pdf_content(pdf)
      pdf.text code, size: 12
      pdf.text organ&.name
      pdf.text box_specification.measure
      pdf.bounding_box([pdf.bounds.right - 60, pdf.bounds.top], width: 60, height: 60) do
        pdf.image StringIO.new(qrcode_enter_png.to_blob), fit: [60, 60], position: :right, vposition: :top
      end
    end

    def enter_url
      Rails.application.routes.url_for(controller: 'ship/boxes', action: 'qrcode', id: code)
    end

    def qrcode_enter_png
      QrcodeUtil.code_png(enter_url, border_modules: 0, fill: 'pink')
    end

    def qrcode_enter_url
      QrcodeUtil.data_url(enter_url)
    end

  end
end
