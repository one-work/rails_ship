module Ship
  class Admin::BoxesController < Admin::BaseController
    before_action :set_box_host
    before_action :set_new_box, only: [:index, :new, :create]
    before_action :set_box, only: [:pdf]

    def index
      q_params = {}
      q_params.merge! default_params

      @boxes = @box_host.boxes.includes(:held_user, :held_organ).default_where(q_params).order(id: :desc).page(params[:page])
    end

    def batch
      5.times do
        @box_host.boxes.build(box_params)
      end
      @box_host.save
    end

    def batch_pdf
      boxes = @box_host.boxes.find params[:ids]
      pdf = BasePdf.new(width: 78.mm, height: 40.mm)
      boxes.each do |box|
        box.pdf_content(pdf)
        pdf.start_new_page
      end

      send_data pdf.render, type: 'application/pdf', disposition: 'inline'
    end

    def pdf
      send_data @box.to_pdf.render, type: 'application/pdf', disposition: 'inline'
    end

    private
    def set_box_host
      @box_host = BoxHost.find params[:box_host_id]
    end

    def set_box
      @box = @box_host.boxes.find params[:id]
    end

    def set_new_box
      @box = @box_host.boxes.build(box_params)
    end

    def box_params
      p = params.fetch(:box, {}).permit(
        :code
      )
      p.merge! default_form_params
    end

  end
end
