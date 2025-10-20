module Ship
  class Our::AddressesController < My::AddressesController

    def index
      q_params = {}
      q_params.merge! params.permit(:station_id)

      @addresses = current_client.organ.addresses.includes(:area).default_where(q_params).page(params[:page])
    end

  end
end
