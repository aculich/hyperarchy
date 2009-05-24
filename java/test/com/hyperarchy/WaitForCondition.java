package com.hyperarchy;


public abstract class WaitForCondition {
  public WaitForCondition() {
    this(null);
  }

  public WaitForCondition(String description) {
    this(500, description);
  }

  public WaitForCondition(long millisecondsUntilTimeout) {
    this(millisecondsUntilTimeout, null);
  }

  public WaitForCondition(long millisecondsUntilTimeout, String description) {
    long startTime = System.currentTimeMillis();
    while (System.currentTimeMillis() < startTime + millisecondsUntilTimeout) {
      if (condition()) return;
    }
    throwTimeoutException(millisecondsUntilTimeout, description);
  }

  private void throwTimeoutException(long millisecondsUntilTimeout, String description) {
    String message = "Timed out after " + millisecondsUntilTimeout + " ms waiting for condition";
    if (description != null) message += ": " + description;
    throw new RuntimeException(message);
  }

  protected abstract boolean condition();
}
