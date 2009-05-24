package com.hyperarchy.model;

import com.hyperarchy.BaseTestCase;

public class SetTest extends BaseTestCase {
  public void testBuildTuple() throws Exception {
    Tuple tuple = candidatesSet.buildTuple();
    assertSame(candidatesSet, tuple.getSet());
  }

  public void testInsert() throws Exception {
    assertFalse(candidatesSet.getTuples().contains(candidiateTuple));
    candidatesSet.insert(candidiateTuple);
    assertTrue(candidatesSet.getTuples().contains(candidiateTuple));
  }
}
