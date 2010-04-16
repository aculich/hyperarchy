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

  describe("wrapper around jQuery.fn.append", function() {
    before(function() {
      _.constructor("TestTemplate", Monarch.View.Template, {
        content: function(params) {
          this.builder.div(params.number.toString());
        }
      });
    });

    after(function() {
      $("#testContent").empty();
      delete window.TestTemplate;
    });

    function testView(number) {
      var view = TestTemplate.toView({number: number});
      view.afterAttach = mockFunction("afterAttach");
      return view;
    }

    it("when attaching an object to the document, invokes afterAttach if present", function() {
      var testContent = $("#testContent");

      var view1 = testView(1);
      testContent.append(view1);
      expect(view1.afterAttach).to(haveBeenCalled, once);

      var view2 = testView(2);
      testContent.prepend(view2);
      expect(view2.afterAttach).to(haveBeenCalled, once);

      var view3 = testView(3);
      view2.replaceWith(view3);
      expect(view3.afterAttach).to(haveBeenCalled, once);

      var view4 = testView(4);
      view3.before(view4);
      expect(view4.afterAttach).to(haveBeenCalled, once);

      var view5 = testView(5);
      view4.before(view5);
      expect(view5.afterAttach).to(haveBeenCalled, once);
    });

    it("when attaching to another object that itself is not yet attach, defers call to afterAttach until the parent is attached", function() {
      var parent = testView(1);
      var child = testView(2);
      var grandchild = testView(3);

      child.append(grandchild);
      expect(grandchild.afterAttach).toNot(haveBeenCalled);
      parent.prepend(child);
      expect(child.afterAttach).toNot(haveBeenCalled);

      $("#testContent").append(parent);
      expect(parent.afterAttach).to(haveBeenCalled, once);
      expect(child.afterAttach).to(haveBeenCalled, once);
      expect(grandchild.afterAttach).to(haveBeenCalled, once);
    });
  });
}});
