var Overlay = (function () {
  function build(body, header) {
    this.transition_end = 'transitionend webkitTransitionEnd oTransitionEnd otransitionend MSTransitionEnd'

    this.$overlay_header = $('<div class="overlay-header">');
    this.$overlay_header_content = $('<h6 class="overlay-header-content">');
    this.$overlay_header.append(this.$overlay_header_content);

    this.$overlay_content = $('<div class="overlay-content">');
    this.$overlay_box = $('<div class="overlay-box">');
    this.$overlay_background = $('<div class="overlay-background">');
    this.$overlay_close = $('<button class="overlay-close">Close</button>');

    this.$overlay_header.append(this.$overlay_close);

    this.$overlay_box.append(this.$overlay_header).append(this.$overlay_content);
    this.$overlay_background.append(this.$overlay_box);

    set_content(body, header);

    $('body').prepend(this.$overlay_background).addClass('no-scroll');
    force_layout_update();

    this.$overlay_background.addClass('visible');
  }

  function force_layout_update() {
    this.$overlay_box.offset();
  }

  function bind_click() {
    $(document).click(function(event) {
      var $target = $(event.target),
        clicked_close = $target.closest('.overlay-close').length,
        clicked_outside = !$target.closest('.overlay-box').length;

      if (clicked_close || clicked_outside) {
        hide();
      }
    });
  }

  function hide(callback) {
    $overlay_background.on(transition_end , function() {
        $(this).remove();

        $('body').removeClass('no-scroll');

        if (typeof callback === 'function') {
          callback();
        }
      }
    );

    $overlay_background.removeClass('visible');
  }

  function set_content(body, header) {
    this.$overlay_header_content.html(header);
    this.$overlay_content.html(body);
    bind_click();
  }

  function show(body, header) {
    if ($('.overlay-background.visible').length) {
      set_content(body, header);
      this.$overlay_background.removeClass('hidden');
    }
    else {
      build(body, header);
    }
  }

  return {
    show: show,
    hide: hide
  }

})();
