module Ship
  class Our::Cart::AddressesController < My::Cart::AddressesController

    def index
      q_params = {}

      @addresses = current_client.organ_addresses.includes(:area).default_where(q_params).order(id: :desc).page(params[:page])
    end

    private
    def set_cart
      @cart = Cart.default_where(default_params).find params[:cart_id]
    end

  end
end
