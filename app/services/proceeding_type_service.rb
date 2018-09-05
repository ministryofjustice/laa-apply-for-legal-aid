class ProceedingTypeService
  def process_proceeding_type(params, application)
    proceeding_types = ProceedingType.where(code: params)
    all_found = proceeding_types.size == params.size
    application.proceeding_types = proceeding_types if all_found
    all_found
  end
end
