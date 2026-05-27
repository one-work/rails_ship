module Ship
  class Board::UsersController < Board::BaseController

    def update
      if current_user
        current_user.set_geo!(params[:longitude], params[:latitude])
      end
    end

  end
end
