---
layout: docs
title: Data-oriented session generation
permalink: /docs/ruleforms/
---


The most immediately user-friendly way to define Clara rules and queries is directly in code using the defrule and defquery macros.  These are intended to be human-readable syntax and are a quick way to start.  Thus one can have usage patterns like the following:

````
(ns rule-ns)
(defrule cold-rule
  [Temperature (= ?temperature temperature)(< temperature -20)]
  =>
  (insert! (->Cold ?temperature)))

(def session (mk-session 'rule-ns))
(def session-2 (mk-session [cold-rule]))
````

The two sessions above (session and session-2) are equivalent.  

In addition to this DSL, Clara also has a data model for rules and queries, and this data can be passed in directly to mk-session without use of the DSL.  For example:

````
(def session-3 (mk-session [(quote {:ns-name rule-ns,
                                    :lhs [{:type clara.rules.testfacts.Temperature,
                                           :constraints [(= ?temperature temperature) (< temperature -20)]}],
                                    :rhs (do (insert! (->Cold ?temperature))),
                                    :name "rule-ns/cold-rule"})]))
`````

This will yield a session that is equivalent to those above.  In fact, the variable cold-rule holds this data structure, which is why the definition form in session-2 works.  This allows usage patterns such as the dynamic creation of rules and using Clara as a compiler target.  For example, a specialized DSL could present a more constrained set of options than Clara's and then compile to Clara rule forms in order to use the latter's execution engine.
