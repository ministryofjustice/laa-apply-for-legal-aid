module AddressHandling
  AddressCollectionItem = Struct.new(:id, :address)

private

  def collect_addresses
    count = AddressCollectionItem.new(nil, t("providers.address_selections.show.addresses_found_text", count: @addresses.size))
    [count] + @addresses.map { |addr| AddressCollectionItem.new(addr.lookup_id, addr.full_address) }
  end

  def address_list_params
    params.require(:address_selection).permit(list: [])[:list]
  end

  def build_addresses_from_form_data
    address_list_params.to_a.map do |address_params|
      Address.from_json(address_params)
    end
  end

  def hyphen_safe_titleize(sentence)
    sentence.to_s&.split(" ")&.map(&:capitalize)&.join(" ")
  end

  def titleize_addresses
    @addresses.each do |a|
      a[:address_line_one] = hyphen_safe_titleize(a[:address_line_one])
      a[:address_line_two] = hyphen_safe_titleize(a[:address_line_two])
      a[:city] = hyphen_safe_titleize(a[:city])
      a[:county] = hyphen_safe_titleize(a[:county])
    end
  end
end
