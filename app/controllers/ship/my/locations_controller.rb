module Ship
  class My::LocationsController < My::BaseController
    before_action :set_line
    before_action :set_location, only: [:show, :edit, :update, :destroy]
    before_action :set_new_location, only: [:new, :create]

    def index
      @locations = Location.page(params[:page])
    end

    private
    def set_line
      @line = Line.find params[:line_id]
    end

    def set_location
      @location = Location.find(params[:id])
    end

    def set_new_location
      @location = @line.locations.build(location_params)
    end

    def location_params
      params.fetch(:location, {}).permit(
        :poiname,
        :poiaddress,
        :cityname,
        :lat,
        :lng
      )
    end

  end
end
