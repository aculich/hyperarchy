Group.fixtures(
  :dating => {
    :name => "Dating Quiz"  
  }
)

Track.fixtures(
  :personality => {
    :group_id => "dating"
  }
)

Subtrack.fixtures(
  :favorites => {
    :track_id => "personality"
  }
)

QuestionSet.fixtures(
  :foods => {
    :subtrack_id => "favorites"
  }
)

Question.fixtures(
  :grain => {
    :stimulus => "What's your favorite grain?",
    :question_set_id => "foods"
  },
  :vegetable => {
   :stimulus => "What's your favorite vegetable?",
   :question_set_id => "foods"
  }
)

Answer.fixtures(
  :grain_quinoa => {
    :body => "Quinoa",
    :correct => true,
    :question_id => "grain"
  },
  :grain_barley => {
    :body => "Barley",
    :correct => false,
    :question_id => "grain"
  },
  :grain_millet => {
    :body => "Millet",
    :correct => false,
   :question_id => "grain"
  },
  :vegetable_daikon => {
    :body => "Daikon",
    :correct => false,
    :question_id => "vegetable"
  },
  :vegetable_kale => {
    :body => "Kale",
    :correct => true,
    :question_id => "vegetable"
  }
)