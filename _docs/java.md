---
layout: docs
title: Java Usage
permalink: /docs/java/
---

Clara offers first-class integration with Java in two ways:

* Java Beans are treated as first-class facts
* A simple Java API makes Clara easy to use

Rules can be loaded very simply by using the [clara.rules.RuleLoader](/javadoc/clara/rules/RuleLoader.html).

{% highlight java %}
static final WorkingMemory emptyMemory =
  RuleLoader.loadRules("clara.examples.java");
{% endhighlight %}

The returned [WorkingMemory](/javadoc/clara/rules/WorkingMemory.html) is an immutable object, and any changes like adding facts or fire rules creates a new WorkingMemory, just as the direct Clojure use does.

_Don't fear: internally, the new WorkingMemory shares most of its state with the previous version, so this is efficient!_

Because the working memory is immutable, it's safe to load your ruleset and save an instance of your WorkingMemory as a static object. Rather than re-created a working memory every time (which can be relatively expensive), we can simply hold onto an "empty" working memory, and reuse it any time we want to start with a blank slate for a new set of facts.

We can then use our working memory. Here we insert some facts -- JavaBeans for a Customer and an Order object:

{% highlight java %}
// Create some facts to add to the working memory.
List facts = Arrays.asList(new Customer("Tim", true), new Order(250));

// Insert some facts and fire the rules.
WorkingMemory memory = emptyMemory.insert(facts).fireRules();
{% endhighlight %}

Finally, we run a query against our working memory and print the results. The name of the query
is simply the _namespace/query-name_, and the _getResult_ method on each result returns the value of the specified field in the query:

{% highlight java %}

List<QueryResult> results = memory.query("clara.examples.java/get-promotions"))

for (QueryResult result: results) {
    System.out.println("Query result: " +
                        result.getResult("?promotion"));
}
{% endhighlight %}

The full source code for this example is [here](https://github.com/rbrush/clara-examples/blob/master/src/main/java/clara/examples/java/ExampleMain.java).
