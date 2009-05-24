package com.hyperarchy.model;

import org.jetlang.core.Callback;
import org.jetlang.fibers.Fiber;
import org.jetlang.fibers.ThreadFiber;

import java.util.ArrayList;
import java.util.List;

public class Identity implements Relation {
  private List<Tuple> tuples;
  private Relation operand;
  private boolean maintained;
  private Fiber fiber;

  public Identity(Relation operand) {
    this.operand = operand;
  }

  public List<Tuple> getTuples() {
    if (!maintained) throw new RuntimeException("Relation must be maintained to call getTuples()");
    return tuples;
  }

  public void onInsert(Fiber fiber, Callback<Tuple> insertCallback) {
    throw new UnsupportedOperationException();
  }

  public void maintain() {
    maintained = true;
    tuples = new ArrayList<Tuple>(operand.getTuples());
    fiber = new ThreadFiber();
    fiber.start();

    operand.onInsert(fiber, new Callback<Tuple>() {
      public void onMessage(Tuple tuple) {
        tuples.add(tuple);
      }
    });
  }
}
