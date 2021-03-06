_.constructor("Membership", Model.Record, {
  constructorInitialize: function() {
    this.columns({
      organizationId: "key",
      userId: "key",
      role: "string",
      pending: "boolean",
      firstName: "string",
      lastName: "string",
      emailAddress: "string",
      lastVisited: "datetime",
      notifyOfNewElections: "string",
      notifyOfNewCandidates: "string",
      notifyOfNewCommentsOnOwnCandidates: "string",
      notifyOfNewCommentsOnRankedCandidates: "string"
    });

    this.belongsTo("organization");
    this.belongsTo("user");
  },

  fullName: function() {
    if (this.firstName() && this.lastName()) {
      return this.firstName() + " " + this.lastName();
    } else {
      return null;
    }
  }
});
