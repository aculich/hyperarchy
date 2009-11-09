require File.expand_path("#{File.dirname(__FILE__)}/../../../monarch_spec_helper")

module Model
  module Relations
    describe Projection do
      attr_reader :projection, :operand, :columns

      before do
        @operand = Blog.join(BlogPost).on(BlogPost[:blog_id].eq(Blog[:id]))
        @columns = [
          ProjectedColumn.new(BlogPost[:id]),
          Blog[:title].as(:blog_title),
          BlogPost[:title].as(:blog_post_title),
          ProjectedColumn.new(Blog[:user_id]),
          ProjectedColumn.new(BlogPost[:body])
        ]
        @projection = Projection.new(operand, columns) do
          def foo; end
        end
      end

      describe "#initialize" do
        it "if a block is provided, class_evals it in the Projection singleton class" do
          projection.should respond_to(:foo)
        end
      end

      describe "#all" do
        it "returns instances of ProjectionRecord that have reader methods for each column in the projection" do
          operand_records = operand.all
          operand_records.should_not be_empty
          all = projection.all
          all.size.should == operand_records.size

          operand_records.each_with_index do |join_record, index|
            blog = join_record[Blog]
            blog_post = join_record[BlogPost]

            projection_record = all[index]

            projection_record.blog_post_title.should == blog_post.title
            projection_record.blog_title.should == blog.title
            projection_record.body.should == blog_post.body
            projection_record.user_id.should == blog.user_id
          end
        end
      end

      describe "#find(id)" do
        it "finds the ProjectionRecord with the given id" do
          operand_record = operand.first
          blog = operand_record[Blog]
          blog_post = operand_record[BlogPost]
          projection_record = projection.find(blog_post.id)

          projection_record.blog_post_title.should == blog_post.title
          projection_record.blog_title.should == blog.title
          projection_record.body.should == blog_post.body
          projection_record.user_id.should == blog.user_id
        end
      end

      describe "#to_sql" do
        it "generates appropriate sql" do
          projection.to_sql.should == %{
            select distinct
              blog_posts.id,
              blogs.title as blog_title,
              blog_posts.title as blog_post_title,
              blogs.user_id,
              blog_posts.body
            from
              blogs,
              blog_posts
            where
              blog_posts.blog_id = blogs.id
          }.gsub(/[  \n]+/, " ").strip
        end
      end
    end
  end
end