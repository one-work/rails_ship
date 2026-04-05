module Ship
  class Admin::ShipmentsController < Admin::BaseController
    before_action :set_line
    before_action :set_cars, :set_lines, :set_drivers, only: [:new, :create, :edit, :update]
    before_action :set_shipment, only: [
      :show, :edit, :update, :destroy, :actions, :leave, :arrive,
      :stations, :unloaded, :unloaded_create, :transfer, :loaded, :loaded_create
    ]
    before_action :set_new_shipment, only: [:new, :create]
    before_action :set_station, only: [:unloaded, :transfer]
    before_action :set_from_line_station, only: [:loaded]
    before_action :set_shipment_log, only: [:leave, :arrive]

    def index
      q_params = {}

      @shipments = @line.shipments.includes(:car, :driver, current_line_station: :station).default_where(q_params).order(load_on: :desc).page(params[:page])
    end

    def new
      @shipment.load_on = Date.today
    end

    def leave
      @shipment_log.left_at = Time.current
      @shipment_log.save
    end

    def arrive
      @shipment_log.arrived_at = Time.current
      @shipment_log.save
    end

    def stations
      @line_stations = @shipment.line.line_stations.includes(:station)
    end

    def loaded
      q_params = {}
      q_params.merge! params.permit(:from_station_id, :station_id)

      @packages = Package.where(current_shipment_id: [@shipment.id, nil]).includes(:station, address: :area).default_where(q_params).order(id: :desc).page(params[:page])
    end

    def loaded_create
      packages = Package.find params[:ids]

      ss = packages.map do |package|
        si = @shipment.shipment_items.find_or_initialize_by(package_id: package.id)
        si.state = 'loaded'
        si.confirm_mode = 'batch'
        si.loaded_at ||= Time.current
        si
      end
      @shipment.class.transaction do
        ss.each(&:save)
      end
    end

    def unloaded
      q_params = {}
      q_params.merge! params.permit(:station_id)

      @packages = @shipment.packages.includes(:station, address: :area).default_where(q_params).order(id: :desc).page(params[:page])
    end

    def unloaded_create
      packages = Package.find params[:ids]

      ss = packages.map do |package|
        si = @shipment.shipment_items.find_or_initialize_by(package_id: package.id)
        si.state = 'unloaded'
        si.confirm_mode = 'batch'
        si.unloaded_at ||= Time.current
        si
      end
      @shipment.class.transaction do
        ss.each(&:save)
      end
    end

    def transfer
      q_params = {
      }

      @packages = @shipment.packages.where.not(station_id: @shipment.line.line_stations.pluck(:station_id)).default_where(q_params).page(params[:page])
    end

    private
    def set_cars
      @cars = Car.default_where(default_params)
    end

    def set_line
      @line = Line.find params[:line_id]
    end

    def set_lines
      @lines = Line.default_where(default_params)
    end

    def set_drivers
      @drivers = Driver.default_where(default_params)
    end

    def set_shipment
      @shipment = Shipment.find params[:id]
    end

    def set_new_shipment
      @shipment = @line.shipments.build(shipment_params)
    end

    def set_from_line_station
      @line_station = @shipment.line.line_stations.find_by station_id: params[:from_station_id]
    end

    def set_station
      @station = Station.find params[:station_id]
    end

    def set_shipment_log
      @shipment_log = @shipment.shipment_logs.find_or_initialize_by(station_id: params[:station_id])
    end

    def shipment_params
      p = params.fetch(:shipment, {}).permit(
        :driver_id,
        :car_id,
        :name,
        :load_on,
        :expected_leave_at,
        :left_at,
        :expected_arrive_at,
        :arrived_at
      )
      p.merge! default_form_params
    end

  end
end
