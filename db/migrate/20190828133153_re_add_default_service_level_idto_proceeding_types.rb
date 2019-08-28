class ReAddDefaultServiceLevelIdtoProceedingTypes < ActiveRecord::Migration[5.2]
  def up
    add_reference :proceeding_types, :default_service_level, type: :uuid

    # now populate the service levels table,then add the references on the proceeding types
    ServiceLevelPopulator.call

    # now find the uuid for the record with service level 3 and update all
    # default_service_level_ids on proceeding types
    service_level = ServiceLevel.find_by!(service_level_number: 3)

    ProceedingType.all.each do |pt|
      pt.update(default_service_level_id: service_level.id)
    end
  end

  def down
    remove_reference :proceeding_types, :default_service_level
  end
end
