module CCMSOpponentIdGenerator
  def generate_ccms_opponent_id
    update!(ccms_opponent_id: CCMS::OpponentId.next_serial_id) if ccms_opponent_id.nil?
    ccms_opponent_id
  end
end
