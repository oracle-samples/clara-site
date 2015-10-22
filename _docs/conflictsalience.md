---
layout: docs
title: Conflict Resolution and Salience
permalink: /docs/conflictsalience/
---

### Conflict Resolution
When a set of inserted facts match multiple rules, we have to answer a question: in what order should the matched rules fire? Resolving this question in a rule engine is referred to as _conflict resolution_.

In almost all cases we should design our rules so that order of firing does not matter. Because Clara, like most rule engines, offers truth maintenance, newly derived information is automatically retracted in case its support changes. Relying on order of rule firing is a poor practice in designing rulesets because it makes rules that should be independent and makes them implicitly depend on one another with a defined ordering. The resulting complexity makes rulesets harder to maintain because rule authors need to keep track of it.

However, there remains some cases where we really do care about the order of execution of rules. Rule right-hand sides may have side effects, for instance. We prefer to avoid side effects for the same reason functional programming does, but sometimes they are necessary.

Order of rule execution can also be important for performance in some rulesets. If a rule is transitively dependent on inserted information from many other rules, it makes sense to fire the dependent rule last. This shouldn't affect _correctness_ -- since truth maintenance will clean up inserted facts that become untrue. But it re-evaluating and automatically retracting facts many times has a cost that adds up if dealing with many thousands of facts in a working memory.

### Salience
Clara offers a simple way to specify conflict resolution called _salience_. Salience is simply a integer property attached to the rule, where rules with higher values will fire before rules with lower values. Here is a simple example:

{% highlight clojure %}
(defrule this-fires-first
  {:salience 100}
  [Person (= ?name name))]
  =>
  (println "Hello," ?name))

(defrule this-fires-last
  {:salience -100}
  [Person (= ?name name) (= ?age age)]
  =>
  (println ?name "is" ?age "years old))
{% endhighlight %}

Rules that don't explicitly define salience have a salience value of zero.

### Specialized Activation Groups
For most users either salience or undefined rule ordering should be sufficient. But starting with Clara 0.8.0, users with specialized needs can also provide arbitrary logic to resolve activation conflicts between rules. This logic is defined by two functions. The first is an _activation group_ function, which given a rule structure returns a value to identify the group in which the rule should be activated. The second is a comparator-style function that defines the ordering of the activation groups themselves. (There is not a defined ordering within a group.)

These can be specified by providing the following options when calling mk-session:

* **:activation-group-fn**, a function applied to production structures and returns the group they should be activated with. It defaults to returning the value of the :salience property on the rule, or 0 if none exists.
* **:activation-group-sort-fn**, a comparator function used to sort the values returned by the above :activation-group-fn. It defaults to >, so rules with a higher salience are executed first.

The above is defined in the documentation for the mk-session function.
