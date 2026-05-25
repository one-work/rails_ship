module Ship
  class Board::UsersController < Board::BaseController

    def update
      current_user.geo = "POINT (#{params[:longitude]} #{params[:latitude]})"
      current_user.save!
    end

    private
    def favorite_params
      params.fetch(:favorite, {}).permit(
        :remark
      )
    end

  end
end
