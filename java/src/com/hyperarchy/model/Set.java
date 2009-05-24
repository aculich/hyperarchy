package com.hyperarchy.model;

import org.jetlang.core.Callback;
import org.jetlang.channels.Channel;
import org.jetlang.channels.MemoryChannel;
import org.jetlang.fibers.Fiber;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class Set implements Relation {
  private Map<String, Attribute> attributesByName = new HashMap<String, Attribute>();
  private String globalName;
  private List<Tuple> tuples = new ArrayList<Tuple>();
  private Channel<Tuple> insertChannel = new MemoryChannel<Tuple>();

  public Set(String globalName) {
    this.globalName = globalName;
  }

  public Map<String, Attribute> getAttributesByName() {
    return attributesByName;
  }

  public String getGlobalName() {
    return globalName;
  }

  public void addAttribute(String name, AttributeType type) {
    attributesByName.put(name, new Attribute(this, name, type));
  }

  public Tuple buildTuple() {
    return new Tuple(this);
  }

  public Attribute getAttributeByName(String attributeName) {
    return attributesByName.get(attributeName);
  }

  public List<Tuple> getTuples() {
    return tuples;
  }

  public void onInsert(Fiber fiber, Callback<Tuple> insertCallback) {
    insertChannel.subscribe(fiber, insertCallback);
  }

  public void insert(Tuple tuple) {
    tuples.add(tuple);
    insertChannel.publish(tuple);
  }
}
