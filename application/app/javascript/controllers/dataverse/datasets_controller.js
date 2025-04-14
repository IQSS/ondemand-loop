import {Controller} from "@hotwired/stimulus"
import $ from "jquery"

function toggleSubmitButton() {
    if ($('input[type="checkbox"][name="file_ids[]"]:checked').length > 0) {
        $('#submit_button').prop('disabled', false);
    } else {
        $('#submit_button').prop('disabled', true);
    }
}

$(document).ready(function () {
    // Initially disable the submit button
    toggleSubmitButton();
    // Listen to change events on checkboxes
    $(document).on('change', 'input[type="checkbox"][name="file_ids[]"]', function () {
        toggleSubmitButton();
        const checked = $(this).is(':checked');
        if (!checked) {
            $('#select_all_files').prop('checked', false);
        }
    });

    $(document).on('change', 'input[type="checkbox"][id="select_all_files"]', function () {
        const checked = $(this).is(':checked');
        $('input[name="file_ids[]"]').prop('checked', checked);
        toggleSubmitButton();
    })
});

export default class extends Controller {}