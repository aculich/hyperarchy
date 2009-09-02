require File.expand_path("#{File.dirname(__FILE__)}/../../eden_spec_helper")

module Model
  describe SqlQuery do
    attr_reader :query
    before do
      @query = SqlQuery.new
    end

    describe "#to_sql" do
      context "when there is only one #from_set" do
        before do
          query.add_from_set(BlogPost.set)
        end

        it "generates a simple select" do
          query.to_sql.should == "select #{query.projected_columns_sql} from blog_posts;"
        end
      end

      context "when there are multiple #conditions" do
        before do
          query.add_from_set(BlogPost.set)
          query.add_condition(Predicates::Eq.new(BlogPost[:blog_id], "grain"))
          query.add_condition(Predicates::Eq.new(BlogPost[:body], "Peaches"))
        end

        it "generates a select with a where clause having all conditions and'ed together" do
          query.to_sql.should == %{select #{query.projected_columns_sql} from blog_posts where blog_posts.blog_id = "grain" and blog_posts.body = "Peaches";}
        end
      end
    end

    describe "#add_from_set" do
      it "adds the given Set to #from_sets" do
        query.add_from_set(BlogPost.set)
        query.from_sets.should == [BlogPost.set]
        query.add_from_set(Blog.set)
        query.from_sets.should == [BlogPost.set, Blog.set]
      end
    end

    describe "#add_condition" do
      it "adds the given Predicate to #conditions" do
        predicate_1 = Predicates::Eq.new(BlogPost[:blog_id], "grain")
        predicate_2 = Predicates::Eq.new(BlogPost[:blog_id], "vegetable")
        query.add_condition(predicate_1)
        query.conditions.should == [predicate_1]
        query.add_condition(predicate_2)
        query.conditions.should == [predicate_1, predicate_2]
      end
    end

    describe "#projected_set" do
      context "if #projected_set= has not been called" do
        it "returns the first Set in #from_sets" do
          query.add_from_set(BlogPost.set)
          query.projected_set.should == BlogPost.set
        end
      end

      context "if #projected_set= has been called" do
        it "returns the Set that was assigned" do
          query.projected_set = Blog.set
          query.projected_set.should == Blog.set
        end
      end
    end
  end
end