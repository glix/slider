(function() {
  var $, page, root;
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };
  $ = jQuery;
  root = this;
  page = $(window);
  root.howl || (root.howl = {});
  $.fn.extend({
    wolfe: function(opts) {
      var defaults, notes__, set;
      defaults = {
        element: 'slide',
        notes: false,
        height: function() {
          return page.height();
        },
        width: function() {
          return page.width();
        },
        wrapper: 'wrapper',
        speed: 1000,
        onLoad: function() {},
        onComplete: function() {}
      };
      set = $.extend(defaults, opts);
      notes__ = function(note) {
        if (set.notes) {
          return typeof console !== "undefined" && console !== null ? console.log('====', note, '====') : void 0;
        }
      };
      return this.each(function() {
        var itemDistance;
        notes__('INIT', set.height, set.width);
        itemDistance = 0;
        howl.events = {
          loaded: false
        };
        howl.isNumeric = function(n) {
          return !isNaN(parseFloat(n)) && isFinite(n);
        };
        howl.debounce = function(fn, delay) {
          var time;
          delay || (delay = 100);
          time = null;
          return function() {
            var context, parameters, start, timer;
            context = this;
            parameters = arguments;
            start = function() {
              return fn.apply(context, parameters);
            };
            clearTimeout(timer);
            return timer = setTimeout(start, delay);
          };
        };
        howl.countItems = function() {
          var count, items, self;
          self = this;
          items = $("." + set.element);
          count = items.length;
          return count - 1;
        };
        howl.processItem = function(index, item) {
          if (index === 0) {
            item.attr('data-position', 0);
            item.addClass('in-viewport');
            item.attr('id', 'item-first');
          }
          if (index >= 1) {
            itemDistance += set.height();
            item.attr('data-position', itemDistance);
          }
          if (index === howl.countItems()) {
            item.attr('id', 'item-last');
          }
          return item.attr('data-number', index);
        };
        howl.processItems = function() {
          var items, self, _height, _width;
          self = this;
          items = $("." + set.element);
          _height = set.height();
          _width = set.width();
          notes__(items);
          return items.each(__bind(function(index, item) {
            notes__(item);
            item = $(item);
            item.width(_width).height(_height);
            return howl.processItem(index, item);
          }, this));
        };
        howl.setState = function() {
          var wrapp;
          notes__('SET WRAP STATE');
          wrapp = $("." + set.wrapper);
          return wrapp.attr('data-animate', 'off');
        };
        howl.wrapItems = function(callNext) {
          var items;
          notes__('WRAP ITEMS');
          items = $("." + set.element);
          items.wrapAll("<div class='" + set.wrapper + "'><div class='" + set.wrapper + "-inner'></div></div>");
          return callNext();
        };
        howl.moveTo = function(location) {
          var current, inner, item, locations, next, outer, prev, setEndState;
          outer = $("." + set.wrapper);
          inner = $("." + set.wrapper + "-inner");
          item = $("." + set.element);
          current = outer.find("." + set.element + ".in-viewport");
          next = current.next();
          prev = current.prev();
          setEndState = function(complete) {
            var ID, fn, inumber;
            clearTimeout(ID);
            inumber = $("." + set.element + ".in-viewport").attr('data-number');
            notes__('TRACK DOTS ' + inumber);
            howl.trackDots(inumber);
            fn = function() {
              complete.apply(this);
              return outer.attr('data-animate', 'off');
            };
            return ID = window.setTimeout(fn, set.speed);
          };
          locations = {
            next: function() {
              notes__('NEXT LOCATION');
              if (current.index() !== howl.countItems()) {
                if (outer.attr('data-animate') === 'off') {
                  outer.attr('data-animate', 'on');
                  inner.css('transform', "translate3d( 0, -" + (next.attr('data-position')) + "px, 0 )");
                  current.removeClass('in-viewport');
                  next.addClass('in-viewport');
                  return setEndState(set.onComplete);
                }
              }
            },
            prev: function() {
              notes__('PREV LOCATION');
              if (current.index() !== 0) {
                if (outer.attr('data-animate') === 'off') {
                  outer.attr('data-animate', 'on');
                  inner.css('transform', "translate3d( 0, -" + (prev.attr('data-position')) + "px, 0 )");
                  current.removeClass('in-viewport');
                  prev.addClass('in-viewport');
                  return setEndState(set.onComplete);
                }
              }
            },
            longHaul: function(index) {
              var fetch;
              if (outer.attr('data-animate') === 'off') {
                fetch = item.eq(index);
                outer.attr('data-animate', 'on');
                inner.css('transform', "translate3d( 0, -" + (fetch.attr('data-position')) + "px, 0 )");
                current.removeClass('in-viewport');
                fetch.addClass('in-viewport');
                return setEndState(set.onComplete);
              }
            }
          };
          if (location === 'next') {
            locations['next']();
          }
          if (location === 'prev') {
            locations['prev']();
          }
          if (howl.isNumeric(location)) {
            return locations['longHaul'](location);
          }
        };
        howl.scrollItems = function() {
          var body, self, wrapp;
          self = this;
          body = $('body');
          wrapp = "." + set.wrapper;
          return body.on('DOMMouseScroll mousewheel', wrapp, function(e) {
            var delta, _this;
            delta = e.originalEvent.wheelDelta / 120;
            _this = $(this);
            notes__(delta);
            if (delta > 0) {
              notes__('SCROLL UP');
              howl.moveTo('prev');
            }
            if (delta < 0) {
              notes__('SCROLL DOWN');
              return howl.moveTo('next');
            }
          });
        };
        howl.createDots = function() {
          var amount, body, dots, i, self;
          self = this;
          amount = howl.countItems();
          body = $('body');
          dots = [];
          dots.push('<div class="dots">');
          for (i = 0; i <= amount; i += 1) {
            dots.push("<span class='dot' data-match='" + i + "'></span>");
          }
          dots.push('</div>');
          body.prepend(dots.join(''));
          $('div.dots').css('margin-top', -($('div.dots').height() / 2));
          return notes__(dots);
        };
        howl.trackDots = function(index) {
          var body, dot, dots, select, self;
          self = this;
          body = $('body');
          dots = body.find('.dots');
          dot = dots.find('.dot');
          select = index;
          dot.removeClass('is-selected');
          return $("*[data-match='" + select + "']").addClass('is-selected');
        };
        howl.navDots = function() {
          var body, dot, dots, self;
          self = this;
          body = $('body');
          dots = body.find('.dots');
          dot = dots.find('.dot');
          return dot.on('click', function(e) {
            var id;
            id = $(this).data('match');
            return howl.moveTo(id);
          });
        };
        howl.onResize = function() {
          var debounce, fn;
          notes__('WINDOW RESIZED');
          fn = function() {
            var current, currentId;
            itemDistance = 0;
            current = $("." + set.element).find('.in-viewport');
            currentId = current.attr('data-number');
            howl.moveTo(currentId);
            return howl.processItems();
          };
          debounce = howl.debounce(fn, 500);
          return page.on('resize', debounce);
        };
        howl.commander = function() {
          howl.processItems();
          howl.wrapItems(howl.setState);
          howl.scrollItems();
          howl.createDots();
          if (howl.events.loaded === false) {
            howl.trackDots(0);
          }
          howl.navDots();
          return howl.events.loaded = true;
        };
        howl.commander();
        return howl.onResize();
      });
    }
  });
}).call(this);
