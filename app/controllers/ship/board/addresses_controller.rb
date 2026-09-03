module Ship
  class Board::AddressesController < My::AddressesController

    def index
      q_params = {}
      q_params.merge! organ_id: nil

      @addresses = current_user.addresses.includes(:area, :station).where(q_params).order(id: :desc).page(params[:page])
      @address = current_user.addresses.build
    end

    private
    def address_params
      super.merge! organ_id: nil
    end

  end
end
