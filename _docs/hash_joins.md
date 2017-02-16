---
layout: perf_docs
title: Hash joins
permalink: /docs/hash_joins/
---

Clara allows rules to be written with constraints that call arbitrary Clojure functions.  Since these constraints can be met on arbitrary inputs and fail on others, using them to join facts can be expensive for sufficiently large numbers of joins and facts.  For example, suppose we have the following rule:

{% highlight clojure %}

(defrecord ExistingRecordCold [temperature location])
(defrecord Temperature [temperature location])
(defrecord NewRecordCold [temperature location])

(defrule new-cold-record
 [?existing-record <- ExistingRecordCold]
 [?colder-temp <- Temperature (= location (:location ?existing-record))
                                          (< temperature (:temperature ?existing-record))]
 =>
 (insert! (map->NewRecordCold
    {:temperature (:temperature ?colder-temp) :location (:location ?colder-temp)})))

{% endhighlight %}

This rule will test every Temperature fact against every ExistingRecordCold fact and, if the constraints in the Temperature condition are satisfied, the rule will be fired with that pair.  Thus matching facts for this rule will be O((number of ExistingRecordCold facts) * (number of Temperature facts)), setting aside any additional complexity from interactions with other rules in the session.  This check should be very fast, but for large numbers of ExistingRecordCold and Temperature facts the checks could add up.  Rules with more conditions can be even more expensive, since instead of testing each pair Clara might need to test each combination of three, four, five, or more facts, depending on the number of conditions.

However, Clara internally supports grouping of facts by bindings.  Suppose we have a rule like:

{% highlight clojure %}
(defrule new-cold-record-hash-join
 [?existing-record <- ExistingRecordCold (= ?loc location)]
 [?colder-temp <- Temperature (= location ?loc)
                              (< temperature (:temperature ?existing-record))]
 =>
 (insert! (map->NewRecordCold
    {:temperature (:temperature ?colder-temp) :location (:location ?colder-temp)})))
{% endhighlight %}

In this rule, Clara will group the ExistingRecordCold facts in a map keyed by the value of ?loc.  When Clara receives a Temperature fact, instead of comparing it against all ExistingRecordCold facts, it will find the location of the Temperature fact, look up that location value in the map of locations to ExistingRecordCold facts, and then compare only against those ExistingRecordCold facts.

It is important to note that in order to get these performance benefits, the test on the value of ?loc in the Temperature condition must be a top-level constraint, not wrapped in other Clojure code.  For example,

{% highlight clojure %}
(defrule new-cold-record-incorrect-hash-join
 [?existing-record <- ExistingRecordCold (= ?loc location)]
 [?colder-temp <- Temperature (and (= location ?loc)
                                   (< temperature (:temperature ?existing-record)))]
 =>
 (insert! (map->NewRecordCold
    {:temperature (:temperature ?colder-temp) :location (:location ?colder-temp)})))
{% endhighlight %}

Clara's compiler will not detect the binding on ?loc that is wrapped inside another constraint body, and will test every ExistingRecordCold-Temperature pair as in the first rule.
