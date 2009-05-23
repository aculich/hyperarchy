package com.hyperarchy;

import com.hyperarchy.model.Set;
import com.hyperarchy.model.AttributeType;
import com.hyperarchy.model.Tuple;
import junit.framework.TestCase;

public abstract class BaseTestCase extends TestCase {
  protected Set electionsSet;
  protected Set candidatesSet;
  protected Tuple electionTuple;
  protected Tuple candidiateTuple;

  @Override
  protected void setUp() throws Exception {
    super.setUp();
    electionsSet = new Set("elections");
    electionsSet.addAttribute("body", AttributeType.String);
    electionTuple = electionsSet.buildTuple();

    candidatesSet = new Set("candidates");
    candidatesSet.addAttribute("body", AttributeType.String);
    candidatesSet.addAttribute("election_id", AttributeType.Id);
    candidiateTuple = candidatesSet.buildTuple();
  }
}
