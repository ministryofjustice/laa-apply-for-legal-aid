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
    if (btn.getAttribute('data-value') === 'hide') {
      btn.addEventListener('click', (e) => {
        e.preventDefault()
        hide(cookieBanner)
      })
    } else {
      btn.addEventListener('click', (e) => {
        e.preventDefault()
        const providerId = document.getElementById('provider-id').textContent.trim()
        const btnValue = e.target.getAttribute('data-value')
        updateCookiePreferences(providerId, btnValue).then(() => {
          const mainContent = cookieBanner.querySelector('#main-cookie-content')
          const newContent = cookieBanner.querySelector(`#${btnValue}-content`)
          hide(mainContent)
          show(newContent)
        }).catch((error) => {
          console.error(error.message)
        })
      })
    }
  })
}

document.addEventListener('DOMContentLoaded', (e) => {
  const cookieBanner = document.querySelector('.govuk-cookie-banner')
  if (cookieBanner) {
    initCookieBanner(cookieBanner)
  }
})
