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
          this.append(this.liForRecord(record, index));
        }, this);

        this.subscriptions.add(relation.onRemoteInsert(function(record, index) {
          var li = this.liForRecord(record, index);
          this.insertAtIndex(li, index);
          if (this.onRemoteInsert) this.onRemoteInsert(record, li);
        }, this));

        this.subscriptions.add(relation.onRemoteUpdate(function(record, changes, index) {
          var li = this.liForRecord(record, index);
          this.insertAtIndex(li, index);
          if (this.onRemoteUpdate) this.onRemoteUpdate(li, record, changes, index);
        }, this));

        this.subscriptions.add(relation.onRemoteRemove(function(record, index) {
          this.liForRecord(record, index).remove();
        }, this));
      }
    },

    insertAtIndex: function(li, index) {
      li.detach();
      var insertBefore = this.find("> :eq(" + index + ")");

      if (insertBefore.length > 0) {
        insertBefore.before(li);
      } else {
        this.append(li);
      }
      this.updateIndices();
    },

    liForRecord: function(record, index) {
      var id = record.id();
      if (this.lisById[id]) {
        return this.lisById[id].detach();
      } else {
        return this.lisById[id] = this.buildElement(record, index);
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
      if (this.lisById) {
        _.each(this.lisById, function(li) {
          li.remove();
        });
      }
      this.lisById = {};
    }
  }
});