module ApplicationMeritsTask
  module Opponent
    class Individual < BaseOpponent
      def full_name
        "#{first_name} #{last_name}".strip
      end
    end
  end
end
