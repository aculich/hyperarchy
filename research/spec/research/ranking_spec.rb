require File.expand_path(File.dirname(__FILE__)) + '/../spec_helper.rb'

describe Ranking do
  attr_accessor :my_election, :unranked
  
  before do
    @my_election = Election.new
    5.times {@my_election.add_candidate}
    @unranked = Ranking::UNRANKED_ID
  end
    
  it "can be added to elections and access their candidate lists" do
    ranking = Ranking.new([0, 1])
    my_election.add_ranking(ranking)
    
    ranking.ranked_candidates.should == [0, 1]
    ranking.unranked_candidates.should == [2, 3, 4]
    my_election.add_candidate
    ranking.unranked_candidates.should == [2, 3, 4, 5]
  end
  
  it "determines relative ranks of candidates, deals with ties" do
    ranking = Ranking.new([0, [1, 2], 3, 4])
    my_election.add_ranking(ranking)
    
    ranking.rank_of_candidate(0).should == 0
    ranking.rank_of_candidate(1).should == 1
    ranking.rank_of_candidate(2).should == 1
    ranking.rank_of_candidate(3).should == 2
    
    ranking.candidates_above(0).should == []
    ranking.candidates_above(1).should == [0]
    ranking.candidates_above(2).should == [0]
    ranking.candidates_above(3).should == [0, 1, 2]
    ranking.candidates_above(4).should == [0, 1, 2, 3]
    
    ranking.candidates_below(0).should == [1, 2, 3, 4]
    ranking.candidates_below(1).should == [3, 4]
    ranking.candidates_below(2).should == [3, 4]
    ranking.candidates_below(3).should == [4]
    ranking.candidates_below(4).should == []
  end
  
  it "places unranked candidates properly" do
    ranking = Ranking.new([0, unranked, 4])
    my_election.add_ranking(ranking)
    
    ranking.default_rank.should == 1
    ranking.rank_of_candidate(0).should == 0
    ranking.rank_of_candidate(1).should == 1
    ranking.rank_of_candidate(2).should == 1
    ranking.rank_of_candidate(4).should == 2
    
    ranking.candidates_above_default.should == [0]
    ranking.candidates_below_default.should == [4]
    ranking.candidates_below(0).should == [1, 2, 3, 4]
    ranking.candidates_below(1).should == [4]
    ranking.candidates_below(2).should == [4]
  end
end

# module Models
#   describe Ranking do
#     describe "after create, update, or destroy" do
#       attr_reader :user, :election, :candidate_1, :candidate_2, :candidate_3
# 
#       before do
#         @user = User.make
#         @election = Election.make
#         @candidate_1 = election.candidates.create(:body => "1")
#         @candidate_2 = election.candidates.create(:body => "2")
#         @candidate_3 = election.candidates.create(:body => "3")
#       end
# 
#       specify "majorities are updated accordingly and #compute_global_ranking is called on the ranking's election" do
#         election.majorities.each do |majority|
#           majority.count.should == 0
#         end
# 
#         # 1
#         mock.proxy(election).compute_global_ranking
#         ranking_1 = election.rankings.create(:user => user, :candidate => candidate_1, :position => 1)
#         find_majority(candidate_1, candidate_2).count.should == 1
#         find_majority(candidate_1, candidate_3).count.should == 1
# 
#         # 1, 2
#         mock.proxy(election).compute_global_ranking
#         ranking_2 = election.rankings.create(:user => user, :candidate => candidate_2, :position => 3)
#         find_majority(candidate_1, candidate_2).count.should == 1
#         find_majority(candidate_2, candidate_1).count.should == 0
#         find_majority(candidate_2, candidate_3).count.should == 1
# 
#         # 1, 3, 2
#         mock.proxy(election).compute_global_ranking
#         ranking_3 = election.rankings.create(:user => user, :candidate => candidate_3, :position => 2)
#         find_majority(candidate_1, candidate_2).count.should == 1
#         find_majority(candidate_1, candidate_3).count.should == 1
#         find_majority(candidate_2, candidate_1).count.should == 0
#         find_majority(candidate_2, candidate_3).count.should == 0
#         find_majority(candidate_3, candidate_1).count.should == 0
#         find_majority(candidate_3, candidate_2).count.should == 1
# 
#         # 1, 2, 3
#         mock.proxy(election).compute_global_ranking
#         ranking_2.update(:position => 1.5)
#         find_majority(candidate_1, candidate_2).count.should == 1
#         find_majority(candidate_2, candidate_1).count.should == 0
#         find_majority(candidate_2, candidate_3).count.should == 1
#         find_majority(candidate_3, candidate_2).count.should == 0
# 
#         # 2, 1, 3
#         mock.proxy(election).compute_global_ranking
#         ranking_1.update(:position => 1.75)
#         find_majority(candidate_1, candidate_2).count.should == 0
#         find_majority(candidate_1, candidate_3).count.should == 1
#         find_majority(candidate_2, candidate_1).count.should == 1
#         find_majority(candidate_3, candidate_1).count.should == 0
# 
#         # 3, 2, 1
#         mock.proxy(election).compute_global_ranking
#         ranking_3.update(:position => 0.5)
#         find_majority(candidate_1, candidate_2).count.should == 0
#         find_majority(candidate_1, candidate_3).count.should == 0
#         find_majority(candidate_2, candidate_1).count.should == 1
#         find_majority(candidate_2, candidate_3).count.should == 0
#         find_majority(candidate_3, candidate_1).count.should == 1
#         find_majority(candidate_3, candidate_2).count.should == 1
# 
#         # 3, 1
#         mock.proxy(election).compute_global_ranking
#         ranking_2.destroy
#         find_majority(candidate_1, candidate_2).count.should == 1
#         find_majority(candidate_1, candidate_3).count.should == 0
#         find_majority(candidate_2, candidate_1).count.should == 0
#         find_majority(candidate_2, candidate_3).count.should == 0
#         find_majority(candidate_3, candidate_1).count.should == 1
#         find_majority(candidate_3, candidate_2).count.should == 1
# 
#         # 1
#         mock.proxy(election).compute_global_ranking
#         ranking_3.destroy
#         find_majority(candidate_1, candidate_2).count.should == 1
#         find_majority(candidate_1, candidate_3).count.should == 1
#         find_majority(candidate_2, candidate_1).count.should == 0
#         find_majority(candidate_2, candidate_3).count.should == 0
#         find_majority(candidate_3, candidate_1).count.should == 0
#         find_majority(candidate_3, candidate_2).count.should == 0
# 
#         mock.proxy(election).compute_global_ranking
#         ranking_1.destroy
# 
#         election.majorities.each do |majority|
#           majority.reload.count.should == 0
#         end
# 
#         # no candidate is ranked any longer, so all have a null position
#         candidate_1.position.should be_nil
#         candidate_3.position.should be_nil
#         candidate_3.position.should be_nil
#       end
#     end
#   end
# end
