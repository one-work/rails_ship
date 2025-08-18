module Ship
  class My::Cart::AddressesController < Ship::My::AddressesController
    before_action :set_cart
    before_action :set_address, only: [:show, :edit, :update, :destroy, :actions]
    before_action :set_new_address, only: [:new, :create]
    before_action :set_stations, only: [:station]

    def index
      q_params = {}
      q_params.merge! params.permit(:station_id)

      @addresses = current_user.addresses.includes(:area).default_where(q_params).order(id: :desc).page(params[:page])
    end

    def new
      @address = current_user.addresses.build(station_id: params[:station_id])
      @address.area = Area.new
      @address.contact_person = current_user.name
      @address.tel = current_account.identity if current_account.is_a?(Auth::Account)
    end

    def create
      @cart.address = @address
      @address.class.transaction do
        @address.save!
        @cart.save!
      end
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
      @cart = current_user.carts.find params[:cart_id]
    end

    def set_new_address
      @address = current_user.addresses.build(address_params)
    end

    def set_address
      @address = Address.find(params[:id])
    end

    def address_params
      params.fetch(:address, {}).permit(
        :station_id,
        :area_id,
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
