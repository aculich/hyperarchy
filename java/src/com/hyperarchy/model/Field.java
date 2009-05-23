package com.hyperarchy.model;

public class Field {
  private Attribute attribute;
  private Object value;

  public Field(Attribute attribute) {
    this.attribute = attribute;
  }

  public Attribute getAttribute() {
    return attribute;
  }

  public void setValue(Object value) {
    this.value = value;
  }

  public Object getValue() {
    return value;
  }
}
