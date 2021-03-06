//= require "../../monarch_spec_helper"

Screw.Unit(function(c) { with(c) {
  describe("jQuery.fn.appendView", function() {
    var view;

    before(function() {
      view = Monarch.View.build(function(b) {
        b.div(function() {
          b.div({id: "foo"});
          b.div({id: "bar"});
        })
      });
    });

    it("constructs an anonymous template with the given function as its content method, then generates a view with it, passing this.builder to the function, and appends it to the current jQuery element", function() {
      var clickCallback = mockFunction("click callback");
      view.find("div#bar").appendView(function(b) {
        b.div({id: "baz"}, "baz").click(clickCallback);
      });
      
      view.find("div#bar > div#baz").click();
      expect(clickCallback).to(haveBeenCalled);
    });
  });

  describe("jQuery.fn.view", function() {
    after(function() {
      $("#testContent").empty();
    });

    it("returns the view object associated with a DOM node", function() {
      var view = Monarch.View.build(function(b) {
        b.div("testing");
      });

      $("#testContent").append(view);
      var newWrapper = $("#testContent").find("div");
      expect(newWrapper.view()).to(eq, view);
    });
  });

  describe("jQuery.fn.bindHtml(record, fieldName)", function() {
    useExampleDomainModel();

    it("assigns the html of the current jquery-wrapped element to the value of the indicated field, and keeps it updated as the field changes", function() {
      var elt = $("<div></div>");
      var blog = Blog.createFromRemote({id: "blog", name: "Arcata Tent Haters"})
      elt.bindHtml(blog, "name");
      expect(elt.html()).to(eq, "Arcata Tent Haters");

      blog.name("Arcata Tent Lovers");
      expect(elt.html()).to(eq, "Arcata Tent Lovers");

      var blog2 = Blog.createFromRemote({id: "blog", name: "Arcata Naan Lovers"});
      elt.bindHtml(blog2, "name");

      expect(elt.html()).to(eq, "Arcata Naan Lovers");

      blog.name("Arcata Tent Burners");
      expect(elt.html()).to(eq, "Arcata Naan Lovers");
    });

    it("if the containing view is removed, destroys the subscription", function() {
      var blog = Blog.createFromRemote({id: "blog", name: "Arcata Tent Haters"});

      var view = Monarch.View.build(function(b) {
          b.div(function() {
            b.h1().ref("h1");
          })
        }
      );

      view.h1.bindHtml(blog, 'name');
      expect(view.h1.html()).to(eq, "Arcata Tent Haters");

      view.remove();
      blog.name("Arcata Tent Lovers");
      expect(view.h1.html()).to(eq, "Arcata Tent Haters");
    });
  });
}});
