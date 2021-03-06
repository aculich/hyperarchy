class Ranking
  attr_accessor :election
  attr_reader   :default_rank
  
  # the position of this keyword in the ranking array indicates the "default rank."
  #  it's a placeholder for all candidates not explicity included in the ranking.
  UNRANKED_ID = "other candidates"
  
  def initialize(the_ranking = [], election = nil)
    @ranking = the_ranking
    @election = election
    
    # if default rank isn't specified, assume unranked candidates are tied for last place
    if not @ranking.include?(UNRANKED_ID)
      @ranking.push(UNRANKED_ID);  end
    @default_rank = @ranking.index(UNRANKED_ID)
  end
  
  # which candidates are in Nth place?
  def [](rank)
    if @ranking[rank] == UNRANKED_ID
      unranked_candidates
    else
      @ranking[rank]
    end
  end
  
  def first
    if @ranking.first == UNRANKED_ID
      unranked_candidates
    else
      @ranking.first
    end
  end
  
  def last
    if @ranking.last == UNRANKED_ID
      unranked_candidates
    else
      @ranking.last
    end
  end  
    
  def inspect
    complete_ranking.inspect
  end
  
  def eql? other_ranking
    if other_ranking.class == Ranking
      complete_ranking == other_ranking.complete_ranking
    else
      complete_ranking == other_ranking
    end
  end
  alias :== :eql?
  
  # in which place is candidate N?
  def rank_of_candidate(candidate_id)
    @ranking.each_index do |rank|
      return rank if Array(@ranking[rank]).include?(candidate_id) 
    end
    return default_rank
  end
  
  # which candidates are explicity ranked?
  def ranked_candidates
    Array(@ranking - [UNRANKED_ID]).flatten.sort
  end
  
  # which candidates are NOT explicity ranked?
  def unranked_candidates
    if @election
      @election.candidate_ids - @ranking.flatten
    else
      []
    end
  end
  
  # which candidates are ranked above candidate N?
  def candidates_above(candidate_id)
    rank = rank_of_candidate(candidate_id)
    candidates_above = Array(@ranking[0...rank])
    if candidates_above.include?(UNRANKED_ID)
      candidates_above = candidates_above - [UNRANKED_ID] + unranked_candidates
    end
    return candidates_above.flatten.sort
  end 
  
  # which candidates are ranked below candidate N? 
  def candidates_below(candidate_id)
    rank = rank_of_candidate(candidate_id)
    candidates_below = Array(@ranking[rank+1...@ranking.length])
    if candidates_below.include?(UNRANKED_ID)
      candidates_below = candidates_below - [UNRANKED_ID] + unranked_candidates
    end
    return candidates_below.flatten.sort
  end 
  
  # which candidates are ranked above those that aren't explicity ranked?
  def candidates_above_default
    Array(@ranking[0...@default_rank]).flatten.sort
  end
  
  # which candidates are ranked below those that aren't explicity ranked?
  def candidates_below_default
    Array(@ranking[@default_rank+1...@ranking.length]).flatten.sort
  end  
  
  protected
  
  def complete_ranking
    complete_ranking = @ranking.dup
    complete_ranking[default_rank] = unranked_candidates
    complete_ranking.delete []
    return complete_ranking
  end
  
end
