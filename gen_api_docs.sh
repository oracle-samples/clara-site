#!/bin/bash

if [ $# -eq 0 ]
  then
    echo "args: clara-directory clara-version"
    exit 1
fi

CLARA_RULES_HOME=$1
CLARA_VERSION=$2

echo "Generating docs in " $CLARA_RULES_HOME " version " $CLARA_VERSION

pushd $CLARA_RULES_HOME
lein codox
lein javadoc
popd

mkdir apidocs/$CLARA_VERSION

cp -r $CLARA_RULES_HOME/target/doc apidocs/$CLARA_VERSION/clojure
cp -r $CLARA_RULES_HOME/javadoc apidocs/$CLARA_VERSION/java
