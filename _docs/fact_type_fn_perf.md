---
layout: perf_docs
title: Custom fact type functions for performance
permalink: /docs/fact_type_fn_perf/
---

As discussed in the Hash Joins section, Clara supports efficiently joining between facts based on bindings.  However, a strategy of using hash joins is not applicable when the problem is not a join between multiple conditions, but rather the check inside a single condition.  Suppose for example that we have the rules

{% highlight clojure %}
(defrecord IdHolder [id])
(defquery even-ids []
     [?even-ids <- (acc/all) :from IdHolder (even? id)])
(defquery odd-ids []
     [?odd-ids <- (acc/all) :from IdHolder (odd? id)])
{% endhighlight %}

Suppose that we insert (->IdHolder 1) into the session.  Clara will make the calls (even? 1) and (odd? 1) to determine which of these queries the IdHolder should match.  However, since a number cannot be both even and odd, it shouldn't be necessary to do this.  In most cases simply doubling the number of calls won't be a major issue, but suppose that instead we had a thousand different rules that asserted that the ID was a specific value.  Something like

{% highlight clojure %}
(defrule rule1
    [IdHolder (= id "A")])
	=>
	;; do something
	)

(defrule rule2
    [IdHolder (= id "AA")]
	=>
	;; do something
	)

(defrule rule3
    [IdHolder (= id "AAA")]
	=>
	;; do something
	)
.....
(defrule rule1000
     [IdHolder (clojure.string/join (repeat 1000 "A"))]
	 =>
	 ;; do something
	 )
{% endhighlight %}	 

The elipses between rule2 and rule3 represent rules that are missing but follow the pattern laid out.  In this case, the id from each IdHolder would be extracted and compared for equality with 1000 diifferent strings, but since these conditions are mutually exclusive this shouldn't be necessary.  The reason for this comparison is that every fact is evaluated against every condition for which its fact type makes it eligible; Clara has no way of knowing that any given IdHolder can match at most one of these rules.  However, given a fact, Clara can determine which conditions its fact type makes it eligible to match in constant time (in addition to the time used by the calls to the :fact-type-fn and :ancestors-fn provided).  General discussion of this functionality can be found on [the fact type customization page](/docs/fact_type_customization).  Thus, in the following example, we will avoid the thousand equality checks per IdHolder fact that we had to perform previously.

{% highlight clojure %}
(defrule rule1
      [[IdHolder "A"]]
	  =>
	  ;; do something
	  )
(defrule rule2
      [[IdHolder "AA"]]
	  =>
	  ;; do something
	  )
(defrule rule3
    [[IdHolder "AAA"]]
	=>
	;; do something
	)
......
(defrule rule1000
     [[IdHolder (clojure.string/join (repeat 1000 "A"))]]
	 =>
	 ;; do something
	 )
(mk-session :fact-type-fn (fn [fact]
                             (cond
                                (instance? IdHolder fact) [IdHolder (:id fact)]
                                :else (type fact))))
{% endhighlight %}	 

Clara sessions can be roughly thought of as containing a map from fact types to conditions that facts of that type are eligible to meet.  This custom :fact-type-fn function will determine the type of each IdHolder fact for rule processing services and then look that type up in this map, rather than essentially iterating over all of the map values to find which ones match.  Note that if we wanted to write conditions on IdHolder as well as on this tuple type format we'd need to customize the :ancestors-fn since the ancestors of a fact type are determined using the return value of the :fact-type-fn.  [The fact type customization page](/docs/fact_type_customization) discusses the interaction of the :fact-type-fn and :ancestors-fn options in more detail.
