---
layout: docs
title: Clara's Approach
permalink: /docs/approach/
---

Clara is based on two core ideas:

1. Expert systems are a good way to represent domain knowledge and untangle complex logic.
2. Expert systems have been hijacked into enterprise software offering limited tooling to business users.

Let's look further at each of these.

## Untangling complex logic
Encoding domain expertise in code forces a lot of wiring on the programmer. Requirements come as a set of loosely-related assertions, and we're left figuring out how to connect them. So we might get something like:

{% highlight text %}
if a person bought more than X items, she is a VIP
if a person has a gold membership since year Y, she is a VIP
if a person is a VIP, send an invitation to a special event.
{% endhighlight %}

Such patterns apply to almost any institution, ranging from business policy to regulation to medical knowledge.

We can break this down into functions and objects, but then we have to explicitly wire the inputs and outputs of each rule. If requirements change to need new input for an *is-vip?* function, we have to update all callers of that function, which could require broad refactoring to make sure they have the needed input. Both functional and object-oriented approaches are subject to such complexity.

The value of a rule engine is that it does all of this wiring for us rather than forcing it on the developer. Business logic can be written as independent units, and the engine itself matches needed inputs with available data, composing complex collections of rules automatically.

The catch is that most rule engines are written in limited languages and are primarily designed to support commercial tools for business users. This leads us to the next idea behind Clara.

## Retaking rules
Martin Fowler described a [major issue with most rule engines](http://martinfowler.com/bliki/RulesEngine.html) well:

> Often the central pitch for a rules engine is that it will allow the business people to specify the rules themselves, so they can build the rules without involving programmers. As so often, this can sound plausible but rarely works out in practice.

Clara avoids this pitfall. It is not targeting business users, but instead aims to *retake* the advantages of rule engines to simplify the job of developers. Clara rules are just code. They live a Clojure namespace, are made of Clojure expressions, and can trivially invoke any function or external library on the platform. Clara just allows developers to write business code in a simpler way.

Note that Clara *can* be used as a core engine to support tools built for a business user. There are several users who are generating rules from business logic, using Clara as the underlying engine. This makes sense, since simple, user-facing tools can be effective if you restrict them to a single domain. But this is outside of Clara itself, where we focus on a developer audience.

## Why Clojure?
There are lots of great reasons to use Clojure for many programming needs, but I'll let Rich Hickey's [Simple Made Easy](http://www.infoq.com/presentations/Simple-Made-Easy) talk cover those. Here are a few distinct advantages of Clojure made it an easy choice for Clara:

### Expressiveness
We didn't want to fall into the trap of most rule engines, which used a limited host language that blocked easy expression or invocation of rich logic. Limited languages are great for limited problems, but they can become an obstacle as problems evolve.

### Reach
Clojure can run almost anywhere Java can run, and ClojureScript can run in any modern web browser.  It also offers excellent interop with host languages, making Clara easily used in any Java project.

### Macros
Lisp-style macros are what makes Clara possible. At its core, Clara is a collection of macros that takes a set of independent rules, identifies and merges commonality, and compiles those rules into an efficient executable structure.

## The best of functional programming with the best of rule engines
Finally, Clara aims to combine the best ideas from functional programming with rule engines. Clara sessions are immutable, shared state structures, like any good Clojure data structure. This offers many advantages, such as:

* The ability to safely share sessions across models
* The ability "roll back" to a previous state by simply holding onto a reference
* The elimination of concurrency bugs and many other types of errors
* The ability to create deep explanation of rules and their relationships because code is data

By building on Clojure's core facilities, Clara inherits many of Clojure's advantages.

This talk from Strangeloop 2014 goes into depth on these topics and more:

<iframe width="560" height="315" src="http://www.youtube.com/embed/Z6oVuYmRgkk" frameborder="0" allowfullscreen></iframe>

## What's next?

* Take your [first steps](/docs/firststeps/) to download and use Clara.
* See details on how to [write rules](/docs/rules).
