import axios from 'axios'
import { hide, show } from './helpers'

async function updateCookiePreferences (providerId, action) {
  const url = `/v1/providers/${providerId}`
  const response = await axios({
    method: 'patch',
    url: url,
    data: { provider: { action: action } }
  })
  return response.status
}

function initCookieBanner (cookieBanner) {
  const buttons = cookieBanner.querySelectorAll('.govuk-button')
  buttons.forEach((btn) => {
    btn.addEventListener('click', (e) => {
      const btnValue = e.target.value
      console.log(e.target.value)
      if (btnValue === 'hide') {
        hide(cookieBanner)
      } else {
        const providerId = document.getElementById('provider-id').textContent.trim()
        updateCookiePreferences(providerId, btnValue).then(() => {
          const mainContent = cookieBanner.querySelector('#main-content')
          const newContent = cookieBanner.querySelector(`#${btnValue}-content`)
          hide(mainContent)
          show(newContent)
        })
      }
    })
  })
}

document.addEventListener ('DOMContentLoaded', (e) => {
  const cookieBanner = document.querySelector('#cookie-banner')
  if (cookieBanner) {
    initCookieBanner(cookieBanner)
  }
})
