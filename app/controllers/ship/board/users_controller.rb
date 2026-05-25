module Ship
  class Board::UsersController < Board::BaseController

    def update
      if current_user
        current_user.set_geo!(params[:longitude], params[:latitude])
      end
    end

    private
    def favorite_params
      params.fetch(:favorite, {}).permit(
        :remark
      )
    end

  end
end
