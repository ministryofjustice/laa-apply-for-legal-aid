class ActorPermission < ApplicationRecord
  belongs_to :permittable, polymorphic: true
  belongs_to :permission
end
