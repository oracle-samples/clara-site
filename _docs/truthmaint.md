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

But suppose the customer returns some goods, reducing the the TotalPurchases below $2000? In many systems we would have to detect that ourselves and write code to remove the PremierCustomer label. But in rule engines like Clara, the engine itself takes care of that for us. If the TotalPurchases condition of the rule becomes false, any facts inserted by the rule are automatically retracted. This keeps the derived knowledge of a session consistent with its support, is the key function of truth maintenance.

Truth maintenance is transative. So if any rules used the PremierCustomer fact to infer further knowledge, that inference would also be retracted.

## Unconditional Insertion of facts
In some cases, users may wish to insert a new fact that never gets retracted, even if it support is lost. This can be done by replacing the *(insert!) function with *(insert-unconditional!)*. They are identitcal, except *insert-unconditional!* will not participate in truth maintenance, and its inserted facts will never be retracted.
