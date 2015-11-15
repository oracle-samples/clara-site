---
layout: docs
title: Accumulators
permalink: /docs/accumulators/
---
Accumulators are used to reason over collections of facts, much like how we might use _map_, _reduce_ and similar operations in Clojure. They are similar to the concept of the same name in Jess and Drools.

The use this structure:

![accumulator expression](/img/diagram/ACCUM_EXPR.png)

Here is a simple accumulator in action:

{% highlight clojure %}
;; Creates an accumulator that selects the item with the newest timestamp field.
(def newest-temp (acc/max :timestamp :returns-fact true))

(defrule get-current-temperature
  [?current-temp <- newest-temp :from [Temperature (= ?location location)]]
  =>
  ; Do something.
  )
{% endhighlight %}
Accumulators may also be used to find minimum, maximum, average values, or do other summarization or selection for a set of matching records.

# Writing Accumulators
Clara provides a rich set of built-in accumulators, but advanced use cases may require customized accumulators over a collection of facts. Accumulator authors use the [accum]({{site.clojuredoc}}clara.rules.accumulators.html#var-accum) function in the clara.rules.accumulators namespace, and must provide these parts:

* **reduce-fn** - A reduce function, in the style of clojure.core.reducers, which reduces a collection of values into a single output
* **combine-fn** - A combine function, in the style of clojure.core.reducers, which combines the outputs of two reduce-fn operations into a new, single output.
* **initial-value** - an optional parameter that will be passed to the reduce-fn if provided
* **retract-fn** - An optional function that accepts a previously reduced output and a fact, and returns a new reduced output with the given fact retracted.
* **convert-return-fn** - an operation that performs some conversion on the reduce/combine value before returning it to the caller

A set of [common accumulators]({{site.clojuredoc}}clara.rules.accumulators.html#var-all) is also pre-defined for convenience.
