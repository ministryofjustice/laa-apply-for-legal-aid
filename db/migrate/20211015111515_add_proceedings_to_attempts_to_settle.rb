class AddProceedingsToAttemptsToSettle < ActiveRecord::Migration[6.1]
  def change
    add_reference :attempts_to_settles, :proceeding,  foreign_key: true, type: :uuid
    add_reference :chances_of_successes, :proceeding, foreign_key: true, type: :uuid
    add_reference :application_proceeding_types_linked_children, :proceeding, type: :uuid, index: { name: 'apt_link_child_proceedings_index' }, foreign_key: true
  end
end
