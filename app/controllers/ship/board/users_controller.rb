module Ship
  class Board::UsersController < Board::BaseController

    def update
      if current_user
        current_user.update geo: RGeo::Geos.factory(srid: 4326).point(params[:longitude], params[:latitude])
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
