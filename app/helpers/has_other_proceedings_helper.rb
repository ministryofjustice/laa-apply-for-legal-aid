module HasOtherProceedingsHelper
  def show_check_proceeding_warning?(proceedings)
    proceedings_to_show_warning = plf_proceedings + sca_proceedings + section_8_proceedings
    proceedings.pluck(:ccms_code).any? { |proceeding| proceeding.in?(proceedings_to_show_warning) }
  end

private

  def plf_proceedings
    %w[PBM04 PBM05 PBM09 PBM11 PBM16 PBM16A PBM16E PBM17 PBM17A PBM17E PBM20 PBM20A PBM20E PBM21 PBM21A PBM21E PBM22 PBM23 PBM24 PBM26 PBM27 PBM28 PBM30 PBM38 PBM38A PBM38E PBM39 PBM39A PBM39E]
  end

  def sca_proceedings
    %w[PB003 PB005 PB006 PB026 PB057 PB059]
  end

  def section_8_proceedings
    %w[SE003 SE003A SE003E SE004 SE004A SE004E SE007 SE007A SE007E SE008 SE008A SE008E SE013 SE013A SE013E SE014 SE014A SE014E]
  end
end
