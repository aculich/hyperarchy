class MajorityGraph
  def initialize
    @graph = RGL::DirectedAdjacencyGraph.new
    @tied_sets = []
  end

  def add_edge(winner_id, loser_id, count)
    puts "add_edge #{winner_id}, #{loser_id}, #{count}"
    
    graph.add_edge(winner_id, loser_id)

    cycles = graph.cycles_with_vertex(winner_id)
    return if cycles.empty?

    puts "edge is within cycles: #{cycles.inspect}"

    if cycles_contain_edge_with_greater_count?(cycles, count)
      puts "removing edge"
      graph.remove_edge(winner_id, loser_id)
    else
      puts "found a tie #{cycles.flatten.uniq.inspect}"
      add_to_tied_sets(SortedSet.new(cycles.flatten.uniq))
    end
  end

  def ranked_candidates
    tied_sets_by_representative_id = {}
    tied_sets.each do |tied_set|
      tied_sets_by_representative_id[tied_set.first] = tied_set
      tied_set.drop(1).each do |candidate_id|
        graph.remove_vertex(candidate_id)
      end
    end

    results = []
    puts "topsort"
    graph.topsort_iterator.each do |candidate_id|

      p candidate_id
      if tied_set = tied_sets_by_representative_id[candidate_id]
        results.push(tied_set.to_a)
      else
        results.push([candidate_id])
      end
    end

    results
  end

  protected
  attr_reader :graph, :tied_sets

  def cycles_contain_edge_with_greater_count?(cycles, count)
    cycle_edges = []
    cycles.each do |cycle|
      cycle.each_cons(2) {|pair| cycle_edges.push(pair)}
      cycle_edges.push([cycle.last, cycle.first])
    end

    cycle_edges.each do |edge|
      if Majority.find(:winner_id => edge[0], :loser_id => edge[1]).pro_count > count
        return true
      end
    end

    return false
  end

  def add_to_tied_sets(new_set)
    tied_sets.each do |existing_set|
      unless existing_set.intersection(new_set).empty?
        existing_set.merge(new_set)
        return
      end
    end
    tied_sets.push(new_set)
  end
end