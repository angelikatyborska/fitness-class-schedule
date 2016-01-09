var Overlay = (function () {
  function build(body, header) {
    this.overlay_header = $('<div class="overlay-header">');
    this.overlay_header_content = $('<h6 class="overlay-header-content">');
    this.overlay_header.append(this.overlay_header_content);

    this.overlay_content = $('<div class="overlay-content">');
    this.overlay_box = $('<div class="overlay-box">');
    this.overlay_background = $('<div class="overlay-background">');
    this.overlay_close = $('<button class="overlay-close">Close</button>');

    this.overlay_header.append(this.overlay_close);

    this.overlay_box.append(this.overlay_header).append(this.overlay_content);
    this.overlay_background.append(this.overlay_box);

    set_content(body, header);

    $('body').prepend(this.overlay_background);

    $(document).click(function(event) {
      var $target = $(event.target);
      if (!$target.closest('.overlay-box').length || $target.closest('.overlay-close').length) {
        destroy();
      }
    });
  }

  function destroy() {
    this.overlay_background.remove();
  }

  function set_content(body, header) {
    this.overlay_header_content.html(header);
    this.overlay_content.html(body);
  }

  function show(body, header) {
    if ($('.overlay-background').length) {
      set_content(body, header)
    }
    else {
      build(body, header);
    }
  }

  return { show: show }

})();
