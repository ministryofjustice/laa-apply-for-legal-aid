module CCMSOpponentIdGenerator
  def generate_ccms_opponent_id
    if ccms_opponent_id.nil?
      update!(ccms_opponent_id: CCMS::OpponentId.next_serial_id)
    end
    ccms_opponent_id
  end
end
