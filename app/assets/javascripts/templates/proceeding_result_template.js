var templates = (function(){
  var proceeding_result_template = function (categoryOfLaw, matterType, proceedingMeaning, proceedingCode) {

    return `<div class="govuk-grid-row proceeding-item" style="display: block;">
              <div class="govuk-grid-column-two-thirds">
                <a class="govuk-caption-m">
                  ` + categoryOfLaw + ' > ' + matterType + `
                </a>
                <span class="govuk-body">` + proceedingMeaning + `</span>
              </div>

              <div class="govuk-grid-column-one-third" style="text-align:right;">
                <input  type="hidden"
                        name="proceeding_type"
                        value="` + proceedingCode + `"
                        id="proceedingType` + proceedingCode + `" />
                <input  type="button"
                        value="Select and continue"
                        class="govuk-button proceeding-link"
                        data-endpoint="/provider/legal_aid_applications"
                        data-method=post
                        data-input="#proceedingType` + proceedingCode+ `" />
              </div>
           </div>`;

  };

  var no_results_template = function() {
    return `<div class="govuk-grid-row proceeding-item" style="display: block;">
              <div class="govuk-grid-column-two-thirds no-results">
                <span class="govuk-body">No results found.</span>
              </div>
            </div>`;
  };

  return {proceeding_result_template: proceeding_result_template, no_results_template: no_results_template};
}());
