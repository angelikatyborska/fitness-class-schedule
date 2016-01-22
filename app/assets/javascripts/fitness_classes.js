var FitnessClasses = (function () {
  function equalize_heights() {
    var $items = $('.fitness-class-box');

    var height = Math.max.apply(Math, $items.map(function() { return $(this).find('.fitness-class-box-content').outerHeight(); }));
    $items.outerHeight(height);
  }


  function init() {
    equalize_heights();

    $(window).on('resize', function() {
      equalize_heights();
    });
  }

  return {
    init: init
  }
})();