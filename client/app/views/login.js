constructor("Views.Login", View.Template, {
  content: function() { with(this.builder) {
    div({id: 'login'}, function() {
      div({id: 'errors', style: 'display:none'});
      div({id: 'loginForm'}, function() {
        label({ 'for': 'emailAddress' }, "email address:");
        input({ id: 'emailAddress', name: 'emailAddress' });
        label({ 'for': 'password' }, "password:");
        input({ id: 'password', name: 'password', type: 'password' });
        button({id: 'loginSubmit'}, "log in").click(function(view) { view.loginSubmitted(); });
      });
      a({id: "signUp", href: "#signup", local: true}, "sign up");
    });
  }},

  viewProperties: {
    loginSubmitted: function() {
      var self = this;
      Server.post('/login', Monarch.Model.Record.prototype.underscoreKeys(this.fieldValues()))
        .onSuccess(function(data) {
          Application.currentUserIdEstablished(data.currentUserId);
          History.load('organization');
        })
        .onFailure(function(data) {
          self.find("#errors").html(Views.ErrorList.toView(data.errors)).show();
        });
    }
  }
});
