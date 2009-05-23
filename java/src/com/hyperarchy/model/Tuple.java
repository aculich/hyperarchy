package com.hyperarchy.model;

import java.util.Map;
import java.util.HashMap;

public class Tuple {
  private Set set;
  private Map<String, Field> fieldsByAttributeName = new HashMap<String, Field>();

  public Tuple(Set set) {
    this.set = set;
    constructFields();
  }

  public Set getSet() {
    return set;
  }

  public Map<String, Field> getFieldsByAttributeName() {
    return fieldsByAttributeName;
  }

  public Field getFieldByAttributeName(String attributeName) {
    return fieldsByAttributeName.get(attributeName);
  }

  private void constructFields() {
    for (Map.Entry<String, Attribute> entry : set.getAttributesByName().entrySet()) {
      fieldsByAttributeName.put(entry.getKey(), new Field(entry.getValue()));
    }
  }

  public void setFieldValue(String attributeName, Object value) {
    getFieldByAttributeName(attributeName).setValue(value);
  }

  public Object getFieldValue(String attributeName) {
    return getFieldByAttributeName(attributeName).getValue();
  }
}
