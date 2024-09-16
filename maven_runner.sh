#!/usr/bin/env bash
echo "START: Running tests..."

# Invoke ParallelTestRunner class
mvn test -Dtest=ParallelTestRunner

if [[ $? -ne 0 ]] ; then
  echo "FINISH: There are test failures, failing build..."
  echo "Exiting with code 1."
  exit 1
else
  echo "FINISH: All tests passed!"
  echo "Exiting with code 0."
  exit 0
fi