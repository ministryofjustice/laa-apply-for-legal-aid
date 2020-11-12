# The REGEXP for the postcode validation is taken from this very detailed stack overflow answer:
# https://stackoverflow.com/questions/164979/uk-postcode-regex-comprehensive/51885364#51885364
# The second REGEXP from the answer section of that comment was used because as part
# of the validation process we are changing postcode to uppercase and removing spaces this allows
# for some simplification of the regular expression

POSTCODE_REGEXP = /\A([A-Z][A-HJ-Y]?[0-9][A-Z0-9]?[0-9][A-Z]{2}|GIR ?0A{2})\z/.freeze
