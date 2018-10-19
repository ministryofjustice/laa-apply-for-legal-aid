var civil_applications = {
    init: function(){
        this.setup_proceeding_search();
        this.setup_clear_search();
    },
    setup_proceeding_search: function(){
        var minimum_char_length = 3;

        $('#proceeding-search').on('keyup', function (e) {
            var current_input = $(this).val().toLowerCase();
            if (current_input.length >= minimum_char_length) {
                $.getJSON("/v1/proceeding_types", function (proceedings_data) {
                  var filtered_proceedings = $.grep(proceedings_data, function (proceeding) {
                    return (proceeding.description.toLowerCase().indexOf(current_input) !== -1);
                  });

                  $("#proceeding-list").empty();

                    if (filtered_proceedings.length !== 0) {
                        $.each(filtered_proceedings, function (_, proceeding) {
                            var proceeding_row = templates.proceeding_result_template(
                                proceeding.category_law,
                                proceeding.matter,
                                proceeding.meaning,
                                proceeding.code
                                );

                            $("#proceeding-list").append(proceeding_row);
                        });
                    } else {
                        var proceeding_row = templates.no_results_template
                        $("#proceeding-list").append(proceeding_row);
                    }
                });
            }
        });
    },
    setup_clear_search: function(){
        $('#clearSearch').click(function (e) {
            $('#proceeding-search').val("");
            $("#proceeding-list").empty();
        });
    }
}

$(function () {
    civil_applications.init();

    $('body').on('click', '.proceeding-link', function(e){
      e.preventDefault();


      $('#proceeding_code').val($(this).attr('data-proceeding-code'));
      $('#proceeding-form').submit();

    });
});
