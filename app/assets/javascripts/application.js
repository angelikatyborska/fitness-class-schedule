// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery/dist/jquery.min.js
//= require jquery.turbolinks
//= require jquery-ui/jquery-ui.min.js
//= require jquery-ujs/src/rails.js
//= require fastclick/lib/fastclick.js
//= require jquery-placeholder/jquery.placeholder.js
//= require jquery.cookie/jquery.cookie.js
//= require modernizr/modernizr.js
//= require foundation/js/foundation.min.js
//= require datetimepicker/jquery.datetimepicker.js
//= require colorpicker/jquery.colorpicker.js
//= require responsive-lightbox/jquery.lightbox.min.js
//= require turbolinks
//= require_tree .

$(document).ready(function() {
  $(document).foundation();

  $('.colorpicker').colorpicker({
    colorFormat: '#HEX'
  });

  $('.gallery:not(.admin-gallery) a').lightbox();
});

