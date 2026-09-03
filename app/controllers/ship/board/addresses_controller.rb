module Ship
  class Board::AddressesController < My::AddressesController

    private
    def address_params
      super.merge! organ_id: nil
    end

  end
end
