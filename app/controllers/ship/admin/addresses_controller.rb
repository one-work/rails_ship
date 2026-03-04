module Ship
  class Admin::AddressesController < Admin::BaseController
    before_action :set_address, only: [:show, :edit, :update, :destroy, :actions]
    before_action :set_new_address, only: [:create]

    def index
      q_params = {}
      q_params.merge! default_params
      q_params.merge! params.permit('user_id')

      @addresses = Address.includes(:area, :station).default_where(q_params).page(params[:page])
    end

    def new
      @address = Address.new address_params
      @address.area ||= Area.new
    end

    def search
      q_params = {}
      q_params.merge! params.permit('name-like')

      @stations = Station.default_where(q_params)
    end

    private
    def set_address
      @address = Address.find(params[:id])
    end

    def set_new_address
      @address = Address.new(address_params)
    end

    def address_params
      p = params.fetch(:address, {}).permit(
        :kind,
        :name,
        :contact_person,
        :tel,
        :detail,
        :area_id,
        :principal,
        :station_id,
        :area_ancestors
      )
      p.merge! default_form_params
    end

  end
end
