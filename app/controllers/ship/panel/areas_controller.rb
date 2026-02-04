module Ship
  class Panel::AreasController < Panel::BaseController
    before_action :set_area, only: [:show, :edit, :update, :destroy]

    def index
      q_params = {}
      q_params.merge! params.permit(:name, 'name-like')

      @areas = Area.unscoped.default_where(q_params).order(id: :asc).page(params[:page])
    end

    private
    def set_area
      @area = Area.unscoped.find params[:id]
    end

    def area_params
      params.fetch(:area, {}).permit(
        :name,
        :popular,
        :published,
        :parent_ancestors
      )
    end

  end
end
