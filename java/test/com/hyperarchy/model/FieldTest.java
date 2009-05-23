package com.hyperarchy.model;

import com.hyperarchy.BaseTestCase;

public class FieldTest extends BaseTestCase {
  public void testSetAndGetValue() throws Exception {
    Field field = candidiateTuple.getFieldByAttributeName("body");
    field.setValue("Asparagus");
    assertEquals("Asparagus", field.getValue());
  }
}
