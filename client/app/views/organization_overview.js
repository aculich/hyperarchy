_.constructor("Views.OrganizationOverview", View.Template, {
  content: function() { with(this.builder) {
    div({id: "organizationOverview"}, function() {
      div({'class': "top grid12"}, function() {
        div({'id': "organizationHeader"}, function() {
          div({'id': "title"}, function() {
            a({href: "#", id: 'createElectionLink', 'class': "glossyBlack roundedButton"}, "Raise A New Question")
              .ref('showCreateElectionFormButton')
              .click('showCreateElectionForm');
            h2("Questions Under Discussion");
          });
          div({style: "clear: both"});

          div({id: 'createElectionForm'}, function() {
            a({'class': "glossyBlack roundedButton"}, "Raise Question")
              .ref('createElectionButton')
              .click('createElection');
            input({placeholder: "Type your question here"})
              .keypress(function(view, e) {
                if (e.keyCode === 13) {
                  view.createElectionButton.click();
                  return false;
                }
              })
              .ref('createElectionInput');
          }).ref('createElectionForm');
        });
      }).ref('topDiv');

      subview('electionsList', Views.SortedList, {
        useQueue: true,
        buildElement: function(election) {
          return Views.ElectionLi.toView({election: election});
        },
        onInsert: function(election, li) {
          li.effect('highlight');
        },
        onUpdate: function(li, election, changeset) {
          if (changeset.updatedAt) li.contentDiv.effect('highlight', {color:"#ffffcc"}, 2000);
          if (changeset.body) li.body.html(changeset.body.newValue);
          if (changeset.voteCount) li.updateVoteCount(changeset.voteCount.newValue);
        }
      });

      div({'class': "grid12"}, function() {
        a({id: "moreQuestions", href: "#"}, "More Questions...")
          .ref('nextPageLink')
          .click('goToNextPage');
      });


      div({'class': "clear"});
      div({'class': "bigLoading", 'style': "display: none;"}).ref('loading');
    });
  }},

  viewProperties: {
    defaultView: true,
    viewName: 'organization',
    itemsPerPage: 16,

    initialize: function() {
      this.subscriptions = new Monarch.SubscriptionBundle();
      this.pageFetchFuturesByOrgId = {};
    },

    navigate: function(state) {
      if (!state.organizationId) {
        $.bbq.pushState({view: 'organization', organizationId: Application.currentUser().lastVisitedOrganization().id()});
        return;
      }
      var organizationId = parseInt(state.organizationId);
      var pageNumber = state.page ? parseInt(state.page) : 1;
      Application.currentOrganizationId(organizationId);
      this.organizationId(organizationId);
      this.pageNumber(pageNumber);
      this.createElectionForm.hide();
      this.showCreateElectionFormButton.show();
    },

    organizationId: {
      afterChange: function(organizationId) {
        if (!this.pageFetchFuturesByOrgId[organizationId]) this.pageFetchFuturesByOrgId[organizationId] = {};
        var membership = this.organization().membershipForCurrentUser();
        if (membership) membership.update({lastVisited: new Date()});
        if (this.pageNumber()) this.assignElectionsRelation();
      }
    },

    organization: function() {
      return Organization.find(this.organizationId());
    },

    pageNumber: {
      afterChange: function() {
        if (this.organizationId()) this.assignElectionsRelation();
      }
    },

    assignElectionsRelation: function() {
      var offset = (this.pageNumber() - 1) * this.itemsPerPage;
      var limit = this.itemsPerPage;
      var elections = this.organization().elections().offset(offset).limit(limit);
      this.electionsRelation(elections);
    },

    electionsRelation: {
      afterChange: function(relation) {
        this.displayElections(relation);
      }
    },

    displayElections: function(elections) {
      this.subscriptions.destroy();

      if (this.electionLisById) {
        _.each(this.electionLisById, function(li) {
          li.remove();
        });
      }
      this.electionLisById = {};

      this.startLoading();

      this.fetchCurrentPage().onSuccess(function() {
        this.stopLoading();
        this.electionsList.relation(elections).onComplete(function() {
          $(window).scrollTop(1); $(window).scrollTop(0); // prevent mouse wheel from sticking in chrome on page transitions
        }, this);
        this.subscribeToVisits(elections);
      }, this);
    },

    pageFetchFutures: function() {
      return this.pageFetchFuturesByOrgId[this.organizationId()];
    },

    fetchCurrentPage: function() {
      var currPage = this.pageNumber();
      var prevPage = currPage - 1;
      var nextPage = currPage + 1;

      var future = Server.get("/fetch_organization_page", {
        items_per_page: this.itemsPerPage,
        page: currPage,
        organization_id: this.organizationId()
      });

      _.each([prevPage, currPage, nextPage], function(page) {
        if (!this.pageFetchFutures()[page]) this.pageFetchFutures()[page] = future;
      }, this)

      return this.pageFetchFutures()[currPage];
    },

    subscribeToVisits: function(elections) {
      this.subscriptions.add(elections.joinThrough(Application.currentUser().electionVisits()).onInsert(function(visit) {
        this.electionsList.elementForRecord(visit.election()).visited();
      }, this));
    },

    editOrganization: function(elt, e) {
      e.preventDefault();
      $.bbq.pushState({view: "editOrganization", organizationId: this.organizationId()}, 2);
    },

    showCreateElectionForm: function(elt, e) {
      Application.welcomeGuide.raiseQuestionClicked();
      this.createElectionForm.slideDown('fast');
      this.showCreateElectionFormButton.hide();
      this.createElectionInput.focus();
      e.preventDefault();
    },

    createElection: function() {
      var body = this.createElectionInput.val();
      if (this.creatingElection || body === "") return;
      this.creatingElection = true;
      this.organization().elections().create({body: body})
        .onSuccess(function(election) {
          this.creatingElection = false;
          this.createElectionInput.val("");
          $.bbq.pushState({view: "election", electionId: election.id()});
        }, this);
    },

    goToNextPage: function(elt, event) {
      var nextPage = this.pageNumber() + 1;
      $.bbq.pushState({page: nextPage});
      event.preventDefault();
    },

    startLoading: function() {
      this.loading.show();
    },

    stopLoading: function() {
      this.loading.hide();
    }
  }
});
