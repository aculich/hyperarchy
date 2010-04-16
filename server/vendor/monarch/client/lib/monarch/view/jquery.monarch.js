(function(Monarch, jQuery) {

jQuery.fn.extend({
  appendView: function(contentFn) {
    this.append(Monarch.View.build(contentFn));
    return this;
  },

  view: function() {
    return this.data('view');
  },

  triggerAttachmentHooks: function(arg) {
    var view = arg.data('view');
    if (_.isFunction(view.afterAttach)) view.afterAttach();
    var notify;
    if (arg.data && (notify = arg.data('notifyAfterAttached'))) {
      _.each(notify, function(elt) {
        this.triggerAttachmentHooks(elt);
      }, this);
    }
  },

  deferAttachmentHooks: function(arg) {
    var notifyAfterAttached = this.data('notifyAfterAttached');
    if (!notifyAfterAttached) {
      notifyAfterAttached = [];
      this.data('notifyAfterAttached', notifyAfterAttached);
    }
    notifyAfterAttached.push(arg);
  },

  hasAttachmentHooks: function(arg) {
    if (!arg.data) return false;
    if (arg.data('notifyAfterAttached')) return true;
    var view = arg.data('view');
    if (!view) return false;
    return view.afterAttach && _.isFunction(view.afterAttach);
  },

  handleAfterAttachHooks: function(args) {
    _.each(args, function(arg) {
      if (!this.hasAttachmentHooks(arg)) return;
      if (arg.parents("body").length == 1) {
        this.triggerAttachmentHooks(arg);
      } else {
        this.deferAttachmentHooks(arg);
      }
    }, this);
  }
});

var attachMethodWrapper = function() {
  var args = _.toArray(arguments);
  var original = args.shift();
  var val = original.apply(this, args);
  this.handleAfterAttachHooks(args);
  return val;
};

_.each(["append", "prepend", "before", "after"], function(attachmentMethod) {
  jQuery.fn[attachmentMethod] = _.wrapMethod(jQuery.fn[attachmentMethod], attachMethodWrapper);
});

})(Monarch, jQuery);
