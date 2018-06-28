import UIkit from 'uikit';
import slideshow from 'uikit/dist/js/components/slideshow';
import parallax from 'uikit/dist/js/components/parallax';
import sticky from 'uikit/dist/js/components/sticky';
import grid from 'uikit/dist/js/components/grid';
import slideset from 'uikit/dist/js/components/slideset';
import lightbox from 'uikit/dist/js/components/lightbox';
import accordion from 'uikit/dist/js/components/accordion';
import clamp from 'clamp-js';

UIkit.sticky(".js-nl-menu-bar", {
  top: -1,
  showup: true
});

$('.js-review-comments').each(function(index) {
  clamp(this, {
    clamp: 6,
    useNativeClamp: false,
    truncationChar: "&nbsp;",
    truncationHTML: '&hellip; <a class="review__read-more" href="#review-' + (index + 1) + '" data-uk-modal="{center:true}">read more</a>'
  });
});
