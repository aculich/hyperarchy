require File.expand_path("#{File.dirname(__FILE__)}/../../../eden_spec_helper")

module Model
  module Relations
    describe Selection do
      describe "class methods" do
        describe ".from_wire_representation" do
          it "builds a Selection with an #operand resolved in the given subdomain" do
            subdomain = User.find("nathan")
            selection = Selection.from_wire_representation({
              "type" => "selection",
              "operand" => {
                "type" => "set",
                "name" => "blog_posts"
              },
              "predicate" => {
                "type" => "eq",
                "left_operand" => {
                  "type" => "column",
                  "set" => "blog_posts",
                  "name" => "blog_id"
                },
                "right_operand" => {
                  "type" => "scalar",
                  "value" => "grain"
                }
              }
            }, subdomain)

            selection.class.should == Relations::Selection
            selection.operand.should == subdomain.blog_posts
            selection.predicate.class.should == Predicates::Eq
            selection.predicate.left_operand.should == BlogPost[:blog_id]
            selection.predicate.right_operand.should == "grain"
          end
        end
      end

      describe "instance methods" do
        attr_reader :operand, :predicate, :selection, :predicate_2, :composite_selection
        before do
          @operand = BlogPost.set
          @predicate = Predicates::Eq.new(BlogPost[:blog_id], "grain")
          @selection = Selection.new(operand, predicate)
          @predicate_2 = Predicates::Eq.new(BlogPost[:body], "Barley")
          @composite_selection = Selection.new(selection, predicate_2)
        end

        describe "#tuples" do
          context "when #operand is a Set" do
            it "executes an appropriate SQL query against the database and returns Tuples corresponding to its results" do
              BlogPost.set.tuples.detect {|t| t.blog_id == "grain"}.should_not be_nil
              tuples = selection.tuples
              tuples.should_not be_empty
              tuples.each do |tuple|
                tuple.blog_id.should == "grain"
              end
            end
          end

          context "when #operand is a Selection" do
            it "executes an appropriate SQL query against the database and returns Tuples corresponding to its results" do
              tuple = composite_selection.tuples.first
              tuple.should_not be_nil
              tuple.blog_id.should == "grain"
              tuple.body.should == "Barley"
            end
          end
        end

        describe "#to_sql" do
          context "when #operand is a Set" do
            it "generates a query with an appropriate where clause" do
              selection.to_sql.should == "select #{operand.columns.map {|a| a.to_sql}.join(", ")} from #{operand.global_name} where #{predicate.to_sql};"
            end
          end

          context "when #operand is another Selection" do
            it "generates a query with a where clause that has multiple conditions" do
              composite_selection.to_sql.should == "select #{operand.columns.map {|a| a.to_sql}.join(", ")} from #{operand.global_name} where #{predicate_2.to_sql} and #{predicate.to_sql};"
            end
          end
        end
      end
    end
  end
end