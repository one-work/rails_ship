module Ship
  class Our::OrdersController < Trade::In::OrdersController
    before_action :set_order, only: [:show, :edit, :update, :payment_types, :edit_payment_type]

    def index
      q_params = {}
      q_params.merge! params.permit(:id, :payment_type, :payment_status, :state)

      @orders = current_organ.organ_orders.includes(:trade_items).default_where(q_params).order(id: :desc).page(params[:page])
    end

    def create
      @order = current_member.orders.build(order_params)
      @trade_items = Trade::TradeItem.where(id: params[:ids])
      @trade_items.each do |trade_item|
        trade_item.order = @order
        trade_item.status = 'ordered'
        trade_item.address_id = params[:address_id]
      end

      if @order.save
        render 'create'
      else
        render :new, locals: { model: current_organ }, status: :unprocessable_entity
      end
    end

    private
    def set_order
      @order = current_organ.organ_orders.find params[:id]
    end

    def order_params
      params.permit(:pay_later)
    end

  end
end

