package com.hyperarchy.model;

import org.jetlang.core.Callback;
import org.jetlang.fibers.Fiber;

import java.util.List;

public interface Relation {
  public List<Tuple> getTuples();
  void onInsert(Fiber fiber, Callback<Tuple> insertCallback);
}
