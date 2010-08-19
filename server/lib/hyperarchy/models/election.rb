class Election < Monarch::Model::Record
  column :organization_id, :key
  column :body, :string
  column :created_at, :datetime
  column :updated_at, :datetime

  has_many :candidates
  has_many :rankings
  has_many :majorities

  belongs_to :organization

  def compute_global_ranking
    puts "compute_global_ranking"
    graph = MajorityGraph.new

    majorities.order_by(Majority[:pro_count].desc, Majority[:con_count].asc).each do |majority|
      if majority.pro_count >= majority.con_count
        graph.add_edge(majority.winner_id, majority.loser_id, majority.pro_count)
      end
    end

    graph.ranked_candidates.each_with_index do |candidates, index|
      candidates.each do |candidate|
        puts "updating #{candidate.body.inspect} from #{candidate.position.inspect} to #{index + 1}"
        candidate.update(:position => index + 1)
      end
    end

    update(:updated_at => Time.now)
  end

  def positive_rankings
    rankings.where(Ranking[:position] > 0)
  end

  def negative_rankings
    rankings.where(Ranking[:position] < 0)
  end

  def positive_candidate_ranking_counts
    times_each_candidate_is_ranked(positive_rankings)
  end

  def negative_candidate_ranking_counts
    times_each_candidate_is_ranked(negative_rankings)
  end

  def times_each_candidate_is_ranked(relation)
    relation.
      group_by(:candidate_id).
      project(:candidate_id, Ranking[:id].count.as(:times_ranked))
  end

  def ranked_candidates
    candidates.
      join_to(rankings).
      project(Candidate)
  end
end
