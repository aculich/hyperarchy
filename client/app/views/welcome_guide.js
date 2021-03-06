_.constructor("Views.WelcomeGuide", View.Template, {
  content: function() { with(this.builder) {
    div({style: "display: none; position: relative;"}, function() {
      div({id: "welcomeGuide", 'class': "dropShadow"}, function() {
        ol({id: "steps"}, function() {
          li({id: "step1", 'class': "pending"}, "1. Raise A Question").ref('step1Header');
          li({id: "step2", 'class': "pending"}, "2. Suggest Answers").ref('step2Header');
          li({id: "step3", 'class': "pending"}, "3. Rank Answers").ref('step3Header');
          li({id: "step4", 'class': "pending"}, "4. Invite Team").ref('step4Header');
          li({id: "gloss"});
        });

        div({id: "currentStep"}, function() {
          div({'class': "step"}, function() {
            h2("Welcome to Hyperarchy!");
            div({'class': "stepDescription"}, function() {
              raw("This is a private discussion area for <em id='welcomeGuideOrganizationName'></em>. Let's get the conversation started by raising a question for your team to discuss. To do that, click on the <strong>Raise a Question</strong> tab in the navigation bar below.");
            })
          }).ref("step1A");
          div({'class': "step"}, function() {
            h2("Try to keep your question open-ended.");
            div({'class': "stepDescription"}, function() {
              raw("Instead of asking \"Should we get pizza for lunch?\", ask \"What should we get for lunch?\", then add \"Pizza\" as an answer in the next step.");
            })
          }).ref("step1B");
          div({'class': "step"}, function() {
            h2("Now suggest an answer to your question...");
          }).ref("step2A");
          div({'class': "step"}, function() {
            h2("Click on the question you just added to suggest some answers.");
          }).ref("step2B");
          div({'class': "step"}, function() {
            h2(function() {
              raw("Click <em>Suggest An Answer</em> to add more ideas. When you're done, vote by dragging your answers into the area marked <em>Your Ranking</em>, with your favorite ideas closer to the top.");
            });
          }).ref("step3A");
          div({'class': "step"}, function() {
            h2("Click on the question you just created to vote.");
          }).ref("step3B");
          div({'class': "step"}, function() {
            h2(function() {
              raw("Enter your teammates names and email addresses in the <em>Members</em> section below.");
            });
          }).ref("step4A");
          div({'class': "step"}, function() {
            h2(function() {
              raw("When you finish voting, click on <em>Invite</em> at the top of the page to invite your team.");
            });
          }).ref("step4B");
          div({'class': "step"}, function() {
            h2(function() {
              raw("When you're done inviting your team, click <em>Back To Questions</em> to continue the conversation.");
            });
          }).ref("step4C");
        });
      });
    });
  }},

  viewProperties: {
    initialize: function() {
      Application.welcomeGuide = this;
      this.find(".step").hide();
      $(window).bind('hashchange', this.hitch('determineStep'));
    },

    organization: {
      afterChange: function(organization) {
        if (organization.dismissedWelcomeGuide() || Application.currentUser().dismissedWelcomeGuide()) {
          this.hide();
          return;
        } else {
          this.find("#welcomeGuideOrganizationName").bindHtml(organization, 'name');
          this.show();
        }

        var keyRelations = [
          organization.elections(),
          organization.candidates(),
          organization.votes(),
          organization.memberships()
        ];

        Server.fetch(keyRelations).onSuccess(function() {
          this.determineStep();
          _.each(keyRelations, function(relation) {
            relation.onInsert(this.hitch('determineStep'));
            relation.onRemove(this.hitch('determineStep'));
          }, this);
        }, this);
      }
    },

    determineStep: function() {
      if (!this.organization()) return;
      
      if (this.organization().elections().empty()) {
        if ($.bbq.getState().view == "newElection") {
          this.setStep(1, "B");
        } else {
          this.setStep(1, "A");
        }
      } else if (this.organization().candidates().empty()) {
        if ($.bbq.getState().view == "election") {
          this.setStep(2, "A");
        } else {
          this.setStep(2, "B");
        }
      } else if (this.organization().votes().empty()) {
        if ($.bbq.getState().view == "election") {
          this.setStep(3, "A");
        } else {
          this.setStep(3, "B");
        }
      } else if (this.organization().memberships().size() == 1) {
        if ($.bbq.getState().view == "editOrganization") {
          this.setStep(4, "A");
          $("#editOrganizationMembers").effect("highlight", {}, 3000);
        } else {
          this.setStep(4, "B");
        }
      } else {
        if ($.bbq.getState().view == "editOrganization") {
          this.setStep(4, "C");
        } else {
          this.finish();
        }
      }
    },

    setStep: function(step, substep) {
      this.step = step;
      this.find('.step').hide();
      this['step' + step + substep].show();

      for (var i = 1; i <= 4; i++) {
        var header = this.stepHeader(i);
        if (i < step) {
          header.removeClass('pending').addClass('done');
        } else if (i == step) {
          header.removeClass('pending done');
        } else {
          header.removeClass('done').addClass('pending');
        }
      }

      $(window).trigger('resize');
    },

    stepHeader: function(step) {
      return this['step' + step + 'Header'];
    },

    finish: function() {
      this.fadeOut(function() {
        $(window).trigger('resize');
      });
      Server.post("/dismiss_welcome_guide", {organization_id: this.organization().id()});
    }
  }
});
