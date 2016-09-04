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
Accumulators may also be used to find minimum, maximum, and average values, or do other summarization or selection for a set of matching records.  Note that we accumulate once per distinct set of bindings.  So, for example, if we have temperatures from 3 different locations, the rule get-current-temperature above will fire three times, once per distinct location.  Note that if an accumulator condition has a binding in its constraints that is not bound by another expression it will only fire if it has matching facts, regardless of whether it has a non-nil initial value.  So, for example:

{% highlight clojure %}
(defrule get-windspeeds-from-location
  [?temp <- [Temperature (= ?location location)]]
  [?wind <- (acc/all) :from [WindSpeed (= ?location location)]]
  =>
  ;; do something
)
{% endhighlight %}

will fire with ?wind as an empty vector (the initial value of the all accumulator) for every Temperature fact if there are no WindSpeed facts.  On the other hand, a rule like
{% highlight clojure %}
(defrule get-windspeeds-at-location
  [?wind <- (acc/all) :from [WindSpeed (= ?location location)]]
  =>
  ;; do something
)
{% endhighlight %}

will not fire in the absence of WindSpeed facts since the ?location binding is not bound by another condition in the rule.  However, if the initial value is nil, then the accumulator will not fire without matching facts in any case.  Note that if the initial value of an accumulator is nil, then a condition using that accumulator will not fire without matching facts regardless of whether it creates new bindings.  In other words, in order to fire without matching facts, an accumulator condition must have a non-nil initial value and not use any bindings that are not created by other conditions in the rule or query.

{% highlight clojure %}
(defrule get-coldest-cold
  [?coldest <- (acc/min :temperature) :from [Cold]]
  =>
  ;; do something
)
{% endhighlight %}

The rule get-coldest-cold will not fire without matching facts since the initial value of the min accumulator is nil.

# Writing Accumulators
Clara provides a rich set of built-in accumulators, but advanced use cases may require customized accumulators over a collection of facts. Accumulator authors use the [accum]({{site.clojuredoc}}clara.rules.accumulators.html#var-accum) function in the clara.rules.accumulators namespace, and must provide these parts:

* **reduce-fn** - A reduce function, in the style of clojure.core.reducers, which reduces a collection of values into a single output.
* **combine-fn** - A combine function, in the style of clojure.core.reducers, which combines the outputs of two reduce-fn operations into a new, single output.
* **initial-value** - An optional parameter that will be passed to the reduce-fn if provided.  If all bindings are bound by other conditions in the rule or query then a non-nil initial value will be used
as the result even if there are no matching facts to accumulate on.
* **retract-fn** - An optional function that accepts a previously reduced output and a fact, and returns a new reduced output with the given fact retracted.
* **convert-return-fn** - an operation that performs some conversion on the reduce/combine value before returning it to the caller

A set of [common accumulators]({{site.clojuredoc}}clara.rules.accumulators.html#var-all) is also pre-defined for convenience.  When writing custom accumulators, note that Clara makes no guarantees regarding the order in which facts will be provided to the accumulator functions.
