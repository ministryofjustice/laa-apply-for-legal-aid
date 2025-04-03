import './src/jquery'

import * as MOJFrontend from '@ministryofjustice/frontend'
import * as GOVUKFrontend from 'govuk-frontend'

import Rails from '@rails/ujs'

// require polyfills via core-js
import 'core-js/stable'

import './src/modules/organisations'
import './src/modules/countries'
import './src/modules/proceedings'
import './src/admin-delete'
import './src/bank_transactions'
import './src/checkbox_control'
import './src/cookie_banner'
import './src/dropzone'
import './src/file-upload-categorisation'
import './src/file-upload-validation'
import './src/helpers'
import './src/no_script'
import './src/print_button'
import './src/start_button'
import './src/table-select-all'
import './src/table-sort'
import './src/worker_waiter'

GOVUKFrontend.initAll()
MOJFrontend.initAll()
Rails.start()
