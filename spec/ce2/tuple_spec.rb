require File.expand_path("#{File.dirname(__FILE__)}/ce2_spec_helper")

describe Tuple do
  describe "metaprogramatic functionality" do
    describe "when a subclass in created" do
      it "assigns its .set to a new Set with the underscored-pluralized name of the class as its #global_name" do
        Answer.set.global_name.should == :answers
      end

      it "adds its assigned .set to Domain #sets_by_name" do
        GlobalDomain.sets_by_name[:answers].should == Answer.set
        GlobalDomain.sets_by_name[:answers].tuple_class.should == Answer
      end

      it "defines an :id Attribute on the subclass" do
        Answer.id.class.should == Attribute
        Answer.id.name.should == :id
        Answer.id.type.should == :string
      end
    end

    describe ".attribute" do
      it "delegates attribute definition to .set" do
        mock(Answer.set).define_attribute(:foo, :string)
        Answer.attribute(:foo, :string)
      end

      it "defines a class method that refers to the Attribute defined on .set" do
        Answer.body.should == Answer.set.attributes_by_name[:body]
      end

      it "defines named instance methods that call #set_field_value and #get_field_value" do
        tuple = Answer.new

        mock.proxy(tuple).set_field_value(Answer.body, "Barley")
        tuple.body = "Barley"
        mock.proxy(tuple).get_field_value(Answer.body)
        tuple.body.should  == "Barley"
      end
    end

    describe ".relates_to_many" do
      it "defines a method that returns the Relation defined in the given block" do
        question = Question.find("grain")
        answers_relation = question.answers
        answers_relation.tuples.should_not be_empty
        answers_relation.tuples.each do |answer|
          answer.question_id.should == question.id
        end
      end
    end

    describe ".relates_to_one" do
      it "defines a method that returns the first Tuple from the Relation defined in the given block" do
        answer = Answer.find("grain_quinoa")
        answer.question.should == Question.find("grain")
      end
    end
  end

  describe "class methods" do
    describe ".create" do
      it "deletages to .set" do
        attributes = { :body => "Amaranth" }
        mock(Answer.set).create(attributes)
        Answer.create(attributes)
      end
    end

    describe ".unsafe_new" do
      it "instantiates a Tuple with the given field values without overriding the value of :id" do
        tuple = Answer.unsafe_new(:id => "foo", :body => "Rice")
        tuple.id.should == "foo"
        tuple.body.should == "Rice"
      end
    end

    describe "#each" do
      specify "are forwarded to #tuples of #set" do
        tuples = []
        stub(Answer.set).tuples { tuples }

        block = lambda {}
        mock(tuples).each(&block)
        Answer.each(&block)
      end
    end
  end

  describe "remote query functionality" do
    def tuple
      @tuple ||= Group.find("dating")
    end

    describe "#build_relation_from_wire_representation" do
      it "delegates to Relation#from_wire_representation with self as the subdomain" do
        representation = {
          "type" => "set",
          "name" => "questions"
        }
        mock(Relations::Relation).from_wire_representation(representation, tuple)
        tuple.build_relation_from_wire_representation(representation)
      end
    end

    describe "#fetch" do
      it "populates a relational snapshot with the contents of an array of wire representations of relations" do
        questions_relation_representation = {
          "type" => "selection",
          "operand" => {
            "type" => "set",
            "name" => "questions"
          },
          "predicate" => {
            "type" => "eq",
            "left_operand" => {
              "type" => "attribute",
              "set" => "questions",
              "name" => "id"
            },
            "right_operand" => {
              "type" => "scalar",
              "value" => "grain"
            }
          }
        }

        answers_relation_representation = {
          "type" => "selection",
          "operand" => {
            "type" => "set",
            "name" => "answers"
          },
          "predicate" => {
            "type" => "eq",
            "left_operand" => {
              "type" => "attribute",
              "set" => "answers",
              "name" => "question_id"
            },
            "right_operand" => {
              "type" => "scalar",
              "value" => "grain"
            }
          }
        }

        snapshot = tuple.fetch([questions_relation_representation, answers_relation_representation])

        questions_snapshot_fragment = snapshot["questions"]
        questions_snapshot_fragment.size.should == 1
        questions_snapshot_fragment["grain"].should == Question.find("grain").wire_representation
      end
    end
  end


  describe "instance methods" do
    def tuple
      @tuple ||= Answer.new(:body => "Quinoa", :correct => true)
    end

    describe "#initialize" do
      it "assigns #fields_by_attribute to a hash with a Field object for every attribute declared in the set" do
        Answer.set.attributes.each do |attribute|
          field = tuple.fields_by_attribute[attribute]
          field.attribute.should == attribute
          field.tuple.should == tuple
        end
      end

      it "assigns the Field values in the given hash" do
        tuple.get_field_value(Answer.body).should == "Quinoa"
        tuple.get_field_value(Answer.correct).should == true
      end

      it "assigns #id to a new guid" do
        tuple.id.should_not be_nil
      end
    end

    describe "#wire_representation" do
      it "returns #fields_by_attribute_name with string-valued keys" do
        tuple.wire_representation.should == tuple.field_values_by_attribute_name.stringify_keys
      end
    end

    describe "#field_values_by_attribute_name" do
      it "returns a hash with the values of all fields indexed by Attribute name" do
        expected_hash = {}
        tuple.fields_by_attribute.each do |attribute, field|
          expected_hash[attribute.name] = field.value
        end

        tuple.field_values_by_attribute_name.should == expected_hash
      end
    end

    describe "#set_field_value and #get_field_value" do
      specify "set and get a Field value" do
        tuple = Answer.new
        tuple.set_field_value(Answer.body, "Quinoa")
        tuple.get_field_value(Answer.body).should == "Quinoa"
      end
    end

    describe "#==" do
      context "for Tuples of the same class" do
        context "for Tuples with the same id" do
          it "returns true" do
            Answer.find("grain_quinoa").should == Answer.unsafe_new(:id => "grain_quinoa")
          end
        end

        context "for Tuples with different ids" do
          it "returns false" do
            Answer.find("grain_quinoa").should_not == Answer.unsafe_new(:id => "grain_barley")
          end
        end
      end

      context "for Tuples of different classes" do
        it "returns false" do
          Answer.find("grain_quinoa").should_not == Question.unsafe_new(:id => "grain_quinoa")
        end
      end
    end
  end
end