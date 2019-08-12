module Admin
  class BenefitTypesController < ApplicationController
    before_action :authenticate_admin_user!
    layout 'admin'.freeze

    # GET /admin/benefit_types
    def index
      @benefit_types = BenefitType.order(:label)
    end

    # GET /admin/benefit_types/1
    def show
      benefit_type
    end

    # GET /admin/benefit_types/new
    def new
      benefit_type
    end

    # GET /admin/benefit_types/1/edit
    def edit
      benefit_type
    end

    # POST /admin/benefit_types
    def create
      @benefit_type = BenefitType.new(benefit_type_params)
      if @benefit_type.save
        redirect_to [:admin, @benefit_type], notice: 'Benefit type was successfully created.'
      else
        render :new
      end
    end

    # PATCH/PUT /admin/benefit_types/1
    def update
      if benefit_type.update(benefit_type_params)
        redirect_to [:admin, benefit_type], notice: 'Benefit type was successfully updated.'
      else
        render :edit
      end
    end

    # DELETE /admin/benefit_types/1
    def destroy
      benefit_type.destroy
      redirect_to admin_benefit_types_url, notice: 'Benefit type was successfully destroyed.'
    end

    private

    def benefit_type
      @benefit_type = params[:id] ? BenefitType.find(params[:id]) : BenefitType.new
    end

    # Only allow a trusted parameter "white list" through.
    def benefit_type_params
      return {} unless params[:benefit_type].present?

      params.require(:benefit_type).permit(:description, :exclude_from_gross_income, :label)
    end
  end
end
