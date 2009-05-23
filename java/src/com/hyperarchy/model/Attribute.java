package com.hyperarchy.model;

public class Attribute {
  private Set set;
  private String name;
  private AttributeType type;

  public Attribute(Set set, String name, AttributeType type) {
    this.set = set;
    this.name = name;
    this.type = type;
  }

  public Set getSet() {
    return set;
  }

  public String getName() {
    return name;
  }

  public AttributeType getType() {
    return type;
  }
}
