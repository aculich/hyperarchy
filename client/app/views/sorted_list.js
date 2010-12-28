_.constructor("Views.SortedList", View.Template, {
  content: function(params) {
    var rootTag = params.rootTag || "ol";
    var rootAttributes = params.rootAttributes || {};
    this.builder.tag(rootTag, rootAttributes);
  },

  viewProperties: {
    initialize: function() {
      this.subscriptions = new Monarch.SubscriptionBundle();
    },

    relation: {
      afterChange: function(relation) {
        if (this.subscriptions) this.subscriptions.destroy();

        this.empty();

        relation.each(function(record, index) {
          this.append(this.elementForRecord(record, index));
        }, this);

        this.subscriptions.add(relation.onRemoteInsert(function(record, index) {
          var element = this.elementForRecord(record, index);
          this.insertAtIndex(element, index);
          if (this.onRemoteInsert) this.onRemoteInsert(record, element);
        }, this));

        this.subscriptions.add(relation.onRemoteUpdate(function(record, changes, index) {
          var element = this.elementForRecord(record, index);
          this.insertAtIndex(element.detach(), index);
          if (this.onRemoteUpdate) this.onRemoteUpdate(element, record, changes, index);
        }, this));

        this.subscriptions.add(relation.onRemoteRemove(function(record, index) {
          this.elementForRecord(record, index).remove();
        }, this));
      }
    },

    insertAtIndex: function(element, index) {
      element.detach();
      var insertBefore = this.find("> :eq(" + index + ")");

      if (insertBefore.length > 0) {
        insertBefore.before(element);
      } else {
        this.append(element);
      }
      this.updateIndices();
    },

    elementForRecord: function(record, index) {
      var id = record.id();
      if (this.elementsById[id]) {
        return this.elementsById[id];
      } else {
        return this.elementsById[id] = this.buildElement(record, index);
      }
    },

    afterRemove: function() {
      this.subscriptions.destroy();
    },

    updateIndices: function() {
      if (!this.updateIndex) return;
      var self = this;
      this.children().each(function(index) {
        self.updateIndex($(this), index);
      });
    },

    empty: function() {
      if (this.elementsById) {
        _.each(this.elementsById, function(element) {
          element.remove();
        });
      }
      this.elementsById = {};
    }
  }
});