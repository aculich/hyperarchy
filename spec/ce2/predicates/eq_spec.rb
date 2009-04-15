require File.expand_path("#{File.dirname(__FILE__)}/../ce2_spec_helper")

module Predicates
  describe Eq do

    describe "class methods" do
      describe ".from_wire_representation" do
        attr_reader :wire_representation
        before do
          @wire_representation = {
            "type" => "eq",
            "left_operand" => left_operand_representation,
            "right_operand" => {
              "type" => "scalar",
              "value" => 2,
            }
          }
        end

        context "when both operands are scalars" do
          def left_operand_representation
            {
              "type" => "scalar",
              "value" => 1,
            }
          end

          it "returns an Eq predicate comparing the two scalars" do
            eq = Eq.from_wire_representation(wire_representation)
            eq.class.should == Eq
            eq.left_operand.should == 1
            eq.right_operand.should == 2
          end
        end

        context "when one of the operands is an attribute" do
          def left_operand_representation
            {
              "type" => "attribute",
              "set" => "answers",
              "name" => "correct"
            }
          end

          it "returns an Eq predicate with the indicated attribute as one of its operands" do
            eq = Eq.from_wire_representation(wire_representation)
            eq.class.should == Eq
            eq.left_operand.should == Answer.correct
            eq.right_operand.should == 2
          end
        end
      end
    end

    describe "instance methods" do
      describe "#to_sql" do
        it "returns the left_operand.to_sql = right_operand.to_sql" do
          Eq.new(Answer.correct, false).to_sql.should == %{answers.correct = "f"}
        end
      end
    end
  end
end