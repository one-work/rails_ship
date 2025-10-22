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

    def set_new_address
      @address = current_client.organ_addresses.build(address_params)
    end

    def set_new_address_program
      area = Area.sure_find [params['provinceName'], params['cityName'], params['countyName']].reject(&:blank?).uniq
      cached_key = [area.id, params['detailInfo'], params['userName'], params['telNumber']].join(',')

      @address = current_client.organ_addresses.find_or_initialize_by(cached_key: cached_key)
      @address.area = area
    end

  end
end
