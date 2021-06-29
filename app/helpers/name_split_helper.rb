module NameSplitHelper
  def split_full_name
    name_parts = normalize_spacing_name.split
    last_name = name_parts.pop
    first_name = name_parts.join(' ')
    first_name = 'unspecified' if first_name.blank?
    [first_name, last_name]
  end

  def normalize_spacing_name
    full_name.squish
  end
end
