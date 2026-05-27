module Ship
  class Board::OrgansController < Board::BaseController

    def update
      if current_organ
        current_organ.set_geo!(params[:longitude], params[:latitude])
      end
    end

  end
end
