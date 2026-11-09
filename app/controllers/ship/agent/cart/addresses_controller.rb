module Ship
  class Agent::Cart::AddressesController < My::Cart::AddressesController
    before_action :set_cart
    before_action :set_address, only: [:show, :edit, :update, :destroy, :actions]
    before_action :set_new_address, only: [:new, :create]
    before_action :set_geo, only: [:new]
    before_action :set_stations, only: [:station]

    def index
      q_params = {}
      q_params.merge! params.permit(:station_id)

      @addresses = current_member.agent_addresses.includes(:area).default_where(q_params).page(params[:page])
    end

    def new
      @address.area = Area.new
    end

    def station
    end

    private
    def set_stations
      @stations = Station.default_where(default_params)
    end

    def set_station
      @station = Station.find params[:station_id]
    end

    def set_not_stations
      @stations = Station.default_where(default_params).where.not(id: @station&.id)
    end

    def set_cart
      @cart = current_member.agent_carts.find params[:cart_id]
    end

    def set_new_address
      @address = @cart.build_address(address_params)
    end

    def set_geo
      @ip_geo = { lat: 28.22778, lng: 112.93886 }
    end

    def set_address
      @address = Address.find(params[:id])
    end

    def address_params
      params.fetch(:address, {}).permit(
        :station_id,
        :contact_person,
        :tel,
        :detail,
        :floor,
        :room,
        :area_ancestors
      )
    end

  end
end
