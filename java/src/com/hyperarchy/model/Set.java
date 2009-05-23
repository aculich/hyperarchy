package com.hyperarchy.model;

import java.util.Map;
import java.util.HashMap;

public class Set {
  private Map<String, Attribute> attributesByName = new HashMap<String, Attribute>();
  private String globalName;

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
}
