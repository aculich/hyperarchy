package com.hyperarchy.model;

import com.hyperarchy.BaseTestCase;

public class TupleTest extends BaseTestCase {
  public void testFieldConstruction() throws Exception {
    Field bodyField = candidiateTuple.getFieldsByAttributeName().get("body");
    assertSame(candidatesSet.getAttributeByName("body"), bodyField.getAttribute());

    Field electionIdField = candidiateTuple.getFieldsByAttributeName().get("election_id");
    assertSame(candidatesSet.getAttributeByName("election_id"), electionIdField.getAttribute());
  }

  public void testSetAndGetFieldValue() throws Exception {
    candidiateTuple.setFieldValue("body", "Asparagus");
    assertEquals("Asparagus", candidiateTuple.getFieldValue("body"));
  }
}
