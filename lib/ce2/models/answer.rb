class Answer < Tuple
  attribute :body, :string
  attribute :question_id, :string
  attribute :correct, :boolean

  #  belongs_to :question
  relates_to_one :question do
    Question.where(Question.id.eq(question_id))
  end
end