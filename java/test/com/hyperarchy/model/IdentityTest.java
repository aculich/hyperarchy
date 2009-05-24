package com.hyperarchy.model;

import com.hyperarchy.BaseTestCase;
import com.hyperarchy.WaitForCondition;

public class IdentityTest extends BaseTestCase {
  private Identity identity;

  protected void setUp() throws Exception {
    super.setUp();
    identity = new Identity(candidatesSet);
  }

  public void testMaintain() throws Exception {
    candidatesSet.insert(candidiateTuple);
    identity.maintain();
    assertTrue(identity.getTuples().contains(candidiateTuple));

    final Tuple anotherTuple = candidatesSet.buildTuple();
    candidatesSet.insert(anotherTuple);

    new WaitForCondition("tuple inserted in operand is inserted into identity") {
      protected boolean condition() {
        return identity.getTuples().contains(anotherTuple);
      }
    };
  }

  public void testGetTuples_WhenNotMaintained_ThrowsRuntimeException() throws Exception {
    try {
      identity.getTuples();
      fail("should have thrown exception");
    } catch (RuntimeException e) {
      // expected
    }
  }
}
