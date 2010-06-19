_.constructor("Views.Invite", View.Template, {
  content: function() { with(this.builder) {
    div({id: "invite"}, function() {
      div({'class': "grid6"}, function() {
        textarea({'class': "largeFont"}).ref('emailAddresses');
      });
      div({'class': "grid6 largeFont"}, "Enter your friends' email addresses, and we'll send them an invitation to join Hyperarchy.");

      div({'class': "grid12"}, function() {
        button('Send Invitations').ref('sendInvitationsButton').click('sendInvitations');
        span({'class': "grayText"}, "Separate with spaces, line-breaks, or commas");
      });
    });
  }},

  viewProperties: {
    viewName: 'invite',

    navigate: function() {
      this.emailAddresses.val("");
    },

    sendInvitations: function() {
      var emailAddresses = this.emailAddresses.val().split(/\s+|\s*,\s*/)
      this.sendInvitationsButton.attr('disabled', true);
      Server.post("/invite", {email_addresses: emailAddresses})
        .onSuccess(function() {
          this.sendInvitationsButton.attr('disabled', false);
          jQuery.bbq.pushState({view: "organization"});
          window.notify("Thank you. Your invitations have been sent.");
        }, this);
    }
  }
});