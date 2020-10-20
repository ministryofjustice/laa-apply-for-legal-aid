module Admin
  class FirmsController < AdminBaseController
    def index
      @firms = Firm.order(:name)
    end
  end
end
