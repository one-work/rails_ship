module Ship
  class Admin::PackagesController < Admin::BaseController
    before_action :set_package, only: [:show, :pdf, :print_data, :shipment_items, :edit, :update, :destroy]
    before_action :set_new_package, only: [:new, :create]
    before_action :set_address, only: [:address]
    before_action :set_stations, only: [:new, :create, :edit, :update]
    skip_before_action :require_user, only: [:print_data] if whether_filter :require_user
    skip_before_action :require_role, only: [:print_data] if whether_filter :require_role

    def index
      q_params = {}
      q_params.merge! default_params
      q_params.merge! params.permit(:address_id)

      @packages = Package.includes(:packageds, address: [:area, :station]).default_where(q_params).order(id: :desc).page(params[:page])
    end

    def address
      q_params = {}
      q_params.merge! default_params
      q_params.merge! params.permit(:address_id)

      @packages = Package.includes(:packageds).default_where(q_params).order(id: :desc).page(params[:page])
    end

    def shipment_items
      @shipment_items = @package.shipment_items
    end

    def pdf
      send_data @package.to_pdf.render, type: 'application/pdf', disposition: 'inline'
    end

    def print_data
      render json: @package.to_cpcl.bytes
    end

    private
    def set_package
      @package = Package.find(params[:id])
    end

    def set_new_package
      @package = Package.new package_params
    end

    def set_address
      @address = Address.find params[:address_id]
    end

    def set_stations
      @stations = Station.default_where(default_params)
    end

    def package_params
      _p = params.fetch(:package, {}).permit(
        :state,
        :expected_on,
        :address_id,
        :user_id,
        :produce_plan_id,
        :from_address_id,
        :from_station_id,
        packageds_attributes: [:item_id]
      )
      _p.merge! default_form_params
    end

  end
end
