import {Controller} from "@hotwired/stimulus"
import $ from "jquery"

$(document).ready(function () {
    // Function to toggle the submit button
    function toggleSubmitButton() {
        if ($('input[type="checkbox"][name="file_ids[]"]:checked').length > 0) {
            $('#submit_button').prop('disabled', false);
        } else {
            $('#submit_button').prop('disabled', true);
        }
    }

    // Initially disable the submit button
    toggleSubmitButton();

    // Listen to change events on checkboxes
    $(document).on('change', 'input[type="checkbox"][name="file_ids[]"]', function () {
        toggleSubmitButton();
    });
});

export default class extends Controller {}