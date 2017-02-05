---
layout: docs
title: Truth Maintenance
permalink: /docs/truthmaint/
---

Clara supports Truth Maintenance for all derived facts by default. This means that Clara keeps track of the _support_ of any fact that is inserted by a rule. If the conditions of the inserting rule become false, the inserted fact is no longer supported, and Clara automatically retracts it from the session.

Consider the following rule:

{% highlight clojure %}
(defrule premier-customer
  "Infer that a person is a premier customer if that
  person has purchased more than $2000 of products."
  [Person (= ?person-id id)]
  [TotalPurchases (> amount 2000) (= ?person-id person-id)]
  =>
  (insert! (->PremierCustomer ?person-id)))
{% endhighlight %}

This is pretty straightforward, inferring when a person is a premier customer. That PremierCustomer fact could then be used by other rules or queries.

But suppose the customer returns some goods, reducing the the TotalPurchases below $2000? In many systems we would have to detect that ourselves and write code to remove the PremierCustomer label. But in rule engines like Clara, the engine itself takes care of that for us. If the TotalPurchases condition of the rule becomes false, any facts inserted by the rule are automatically retracted. This keeps the derived knowledge of a session consistent with its support, which is the key function of truth maintenance.

Truth maintenance is transitive. So if any rules used the PremierCustomer fact to infer further knowledge, that inference would also be retracted.  As a result we can treat rules sessions that consistently use truth maintenance as collections of purely declarative statements rather than procedural code.  Please see [this example](https://github.com/cerner/clara-examples/blob/master/src/main/clojure/clara/examples/truth_maintenance.clj) in the clara-examples project for an illustration of truth maintenance.

## Unconditional Insertion of facts
In some cases, users may wish to insert a new fact that never gets retracted, even if its support is lost. This can be done by replacing the *(insert!)* function with *(insert-unconditional!)*. They are identical, except *insert-unconditional!* will not participate in truth maintenance, and its inserted facts will never be retracted.  As a result rule execution order will have an impact on the final state of the session, unlike in sessions that consistently use truth maintenance, and the user will need to take this into account when designing rules.  
