$(document).ready(function() {
  console.log(location.hash)
  if (location.hash && /^#schedule\-item\-/.test(location.hash) ) {
    $(window).scrollTop($(location.hash).offset().top - 15);
    $(location.hash).addClass('highlight');
  }
});

