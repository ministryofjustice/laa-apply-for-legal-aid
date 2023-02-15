import axios from 'axios'
import { hide, show } from './helpers'

async function updateCookiePreferences (providerId, action) {
  const url = `/v1/providers/${providerId}`
  const response = await axios({
    method: 'patch',
    url,
    data: { provider: { action } }
  })
  return response.status
}

function initCookieBanner (cookieBanner) {
  const buttons = cookieBanner.querySelectorAll('.govuk-button')
  buttons.forEach((btn) => {
    if (btn.value === 'hide') {
      btn.addEventListener('click', (e) => {
        hide(cookieBanner)
      })
    } else {
      btn.addEventListener('click', (e) => {
        const providerId = document.getElementById('provider-id').textContent.trim()
        const btnValue = e.target.value
        updateCookiePreferences(providerId, btnValue).then(() => {
          const mainContent = cookieBanner.querySelector('#main-cookie-content')
          const newContent = cookieBanner.querySelector(`#${btnValue}-content`)
          hide(mainContent)
          show(newContent)
        })
      })
    }
  })
}

document.addEventListener('DOMContentLoaded', (e) => {
  const cookieBanner = document.querySelector('#cookie-banner')
  if (cookieBanner) {
    initCookieBanner(cookieBanner)
  }
})
