Given('the page is accessible') do
  # skip aria-allowed-attr to allow for gov_uk conditional radio buttons
  steps %(Then the page should be axe clean skipping: region, aria-allowed-attr)
end
