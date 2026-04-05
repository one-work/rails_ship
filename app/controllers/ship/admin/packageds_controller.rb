module Ship
  class Admin::PackagedsController < Admin::BaseController
    before_action :set_package

    def index
      @packageds = @package.packageds.includes(:item).page(params[:page])
    end

    private
    def set_package
      @package = Package.find params[:package_id]
    end

  end
end
