$(document).ready(() => {
  if ($('input#original_files').length) {

    const file_input = $('#original_files')
    const form = file_input.parents('form')
    const error_summary_container = $('#files-errors-container')
    const uploaded_files_table_container = $('#uploaded-files-table-container')
    const authenticity_token = $("[name=authenticity_token]").val()
    const image_loading_small = window.LAA_VARS.images.loading_small
    const copy_uploading = window.LAA_VARS.locales.generic.uploading

    function send_files(files, callback) {
      const form_data = new FormData()

      form_data.append('authenticity_token', authenticity_token)
      Array.from(files).forEach(file => form_data.append('statement_of_case[original_files][]', file))

      $.ajax({
        url: form.attr('action'),
        data: form_data,
        processData: false,
        contentType: false,
        type: form.find('[name=_method]').val().toUpperCase(),
        success: callback
      })
    }

    function show_uploading_files(files) {
      const rows = Array.from(files).map(file => (
        `
          <tr class="govuk-table__row">
            <td class="govuk-table__cell">${file.name}</td>
            <td class="govuk-table__cell"></td>
            <td class="govuk-table__cell no-wrap">
              <img src="${image_loading_small}" class="small-loading-image"/>
              ${copy_uploading}
            </td>
            <td class="govuk-table__cell"></td>
          </div>
        `
      ))
      uploaded_files_table_container.find('table').show().find('tbody').append(rows.join(''))
    }

    function toggle_errors_class(show) {
      uploaded_files_table_container
        .parents('.govuk-form-group')
        .first()
        .toggleClass('govuk-form-group--error', show)
    }

    function replace_errors_summary(error_summary) {
      error_summary_container.html(error_summary)
      toggle_errors_class(!!error_summary)
    }

    function replace_files_table(uploaded_files_table) {
      uploaded_files_table_container.html(uploaded_files_table)
    }

    file_input.on('change', (event) => {
      const file_input = event.target
      if (!file_input.files.length) return

      show_uploading_files(file_input.files)
      replace_errors_summary('')

      send_files(file_input.files, result => {
        replace_files_table(result.uploaded_files_table)
        replace_errors_summary(Object.keys(result.errors).length ? result.error_summary : '')
      })

      $(file_input).val('');
    })

    uploaded_files_table_container.on('submit', 'form', (event) => {
      const form = $(event.target)
      $.ajax({
        url: `${form.attr('action')}?${form.serialize()}`,
        type: form.find('[name=_method]').val().toUpperCase(),
        success: () => {
          form.parents('tr').first().remove()

          if (uploaded_files_table_container.find('tbody tr').length == 0)
            uploaded_files_table_container.find('table').hide()
        }
      })
      return false
    })
  }
})
