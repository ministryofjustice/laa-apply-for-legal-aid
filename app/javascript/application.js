import './src/jquery'

import { initAll } from 'govuk-frontend'
import Rails from '@rails/ujs'

// require polyfills via core-js
import 'core-js/stable'

import './src/modules/organisations'
import './src/modules/countries'
import './src/modules/proceedings'
import './src/accessible-autocomplete'
import './src/admin-delete'
import './src/bank_transactions'
import './src/checkbox_control'
import './src/cookie_banner'
import './src/dropzone'
import './src/file-upload-validation'
import './src/helpers'
import './src/modal-dialogue'
import './src/no_script'
import './src/print_button'
import './src/start_button'
import './src/table-select-all'
import './src/table-sort'
import './src/worker_waiter'

initAll()
Rails.start()
