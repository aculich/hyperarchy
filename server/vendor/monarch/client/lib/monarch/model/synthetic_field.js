(function(Monarch) {

_.constructor("Monarch.Model.SyntheticField", Monarch.Model.Field, {
  initialize: function(fieldset, column, signal) {
    this.fieldset = fieldset;
    this.local = (fieldset instanceof Monarch.Model.LocalFieldset);
    this.signal = signal;
    this.column = column;
    this.subscribeToFieldUpdates();
  },


  value: {
    reader: function() {
      return this.local ? this.signal.localValue() : this.signal.remoteValue();
    },

    writer: function(value) {
      if (!this.column.setter) throw new Error("No setter method defined on the synthetic column " + this.column.name);
      return this.column.setter.call(this.fieldset.record, value);
    }
  },

  dirty: function() {
    return this.signal.localValue() !== this.signal.remoteValue();
  },

  // private

  subscribeToFieldUpdates: function() {
    var updateHandler = function(newValue, oldValue) {
      this.fieldset.fieldUpdated(this, newValue, oldValue);
      if (this.fieldset.updateEventsEnabled && this.onUpdateNode) this.onUpdateNode.publish(newValue, oldValue);
    };

    if (this.local) {
      this.signal.onLocalUpdate(updateHandler, this);
    } else {
      this.signal.onRemoteUpdate(updateHandler, this);
    }
  }
});

})(Monarch);
