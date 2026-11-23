module Ship
  class Admin::Order::AddressesController < Admin::AddressesController
    before_action :set_address, only: [:show, :edit, :update, :destroy, :actions]
    before_action :set_new_address, only: [:new, :create]
    before_action :set_geo, only: [:new, :edit]

    def index
      q_params = {}
      q_params.merge! params.permit(:station_id)

      @addresses = current_member.agent_addresses.includes(:area).default_where(q_params).page(params[:page])
    end

    def new_ai
    end

    def ai
      r = Address.parse(params[:content])
      area = Area.sure_find r[:area]

      @address = @cart.build_address(
        contact_person: r[:contact_person],
        tel: r[:tel],
        detail: r[:detail],
        area_id: area.id
      )
    end

    def new
      @address.area = Area.new
    end

    private
    def set_order
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
