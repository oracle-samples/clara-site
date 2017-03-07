---
layout: docs
title: Durability
permalink: /docs/durability/
---

### Overview ###

The [clara.rules.durability]({{site.clojuredoc}}clara.rules.durability.html) namespace offers functions to serialize and to deserialize Clara sessions.  The motivation and goals of this durability layer are described in [issue 198](https://github.com/cerner/clara-rules/issues/198).

There are two protocols and four functions that need to be understood in order to work with the Clara durability layer.  The API for these functions and protocols is documented extensively in the inline Clojure docs where they are defined.  For quick reference the relevant docs listed below:

(All in the `clara.rules.durability` namespace)

##### Protocols ######

* [ISessionSerializer]({{site.clojuredoc}}clara.rules.durability.html#var-ISessionSerializer)
* [IWorkingMemorySerializer]({{site.clojuredoc}}clara.rules.durability.html#var-IWorkingMemorySerializer)

##### Functions ######

* [serialize-rulebase]({{site.clojuredoc}}clara.rules.durability.html#var-serialize-rulebase)
* [deserialize-rulebase]({{site.clojuredoc}}clara.rules.durability.html#var-deserialize-rulebase)
* [serialize-session-state]({{site.clojuredoc}}clara.rules.durability.html#var-serialize-session-state)
* [deserialize-session-state]({{site.clojuredoc}}clara.rules.durability.html#var-deserialize-session-state)

Let's look at a few examples of how to use the durability functionality.

### Setup used in all examples ###

{% highlight clojure %}
(ns clara.example.durability
  (:require [clara.rules :as r]
            [clara.rules.durability :as d]
            [clara.rules.durability.fressian :as df]
            ;; The contents of this fake ns don't matter here.
            [some.example.rule.ns :as ex] 
            [clojure.java.io :as io]))

;;; Define a basic implementation of the `d/IWorkingMemorySerializer`
;;; protocol that holds all working memory facts in memory instead of
;;; serializing it out of process.  This will be discussed more later.
(defrecord LocalMemorySerializer [holder]
  d/IWorkingMemorySerializer
  (serialize-facts [_ fact-seq]
    (reset! holder fact-seq))
  (deserialize-facts [_]
    @holder))

;;;; Example session data in a few forms.

(def base-session
  "A session with no working memory changes for demonstration purposes."
  (r/mk-session 'some.example.rule.ns))

(def fired-session
  "A fired session with working memory changes for demonstration purposes."
  (-> base-session
      (r/insert ex/facts)
      r/fire-rules))

{% endhighlight %}

The `clara.rules.durability` namespace defines the public Clara durability API.  Clara does not hardcode itself to any particular serialization format for any serialization.  Fressian is a reasonable and efficient choice for serializing a session's rulebase, which is the Rete-based graph structure that is built from the rules and queries of the session.  Due to this, Clara provides a performant implementation of the `d/ISession` protocol that is based on Fressian.

The `clara.rules.durability.fressian` namespace is optional.  If this namespace is used in a project using Clara, that consumer must provide a compatible Fressian dependency (see the Clara `project.clj` to see what it has been tested against).

Clara (currently) does not provide any default implementations of the `d/IWorkingMemorySerializer` (see [issue 262](https://github.com/cerner/clara-rules/issues/262) for more on this).  In these examples, a "dummy" implementation will be used, `LocalMemorySerializer`, which holds the working memory facts in memory in a dereferenceable holder, such as an atom.  This will be discussed more later.

### Serialize the full session state ###

{% highlight clojure %}

;;;; Define some files to demonstrate the different way to serialize
;;;; session data.

(def full-session-file
  "A file to hold the serialized session rulebase AND working memory data."
  (io/file "full-session-file.dat"))

;;;; Serializing the full state of session, including the rulebase.

(def wm-serializer (->LocalMemorySerializer (atom nil)))

(with-open [os (io/output-stream full-session-file)]
  (d/serialize-session-state fired-session
                             (df/create-session-serializer os)
                             wm-serializer
                             ;; The default is false, so this is necessary to serialize the full
                             ;; session state.  Rationale for that is provided later.
                             {:with-rulebase? true}))
(def deserialized-session
  (with-open [is (io/input-stream full-session-file)]
    (d/deserialize-session-state (df/create-session-serializer is)
                                 wm-serializer)))
{% endhighlight %}

In this basic example, the `deserialized-session` would be restored to a session that functions equivalently to the original `fired-session`.  The `deserialized-session` could have more facts inserted and/or retracted and fired again and queried again.

In the typical usage, deserialization of the session would be done in a separate process space from the original creation of the session.  It is important to understand that Clara durability will assume the same Clojure runtime environment is loaded prior to calling deserialization.  So any namespaces that must be required prior to deserializing the session, must be loaded via something like `require`.  This data could be something serialized along separately (such as in a separate EDN environment metadata file/stream) in a user-specific way.

### Serialize the rulebase separately from the working memory ###

{% highlight clojure %}

;;;; Define some files to demonstrate the different way to serialize session data.

(def rulebase-file
  "A file to hold the serialized session rulebase without the working memory."
  (io/file "rulebase-file.dat"))

(def working-memory-file
  "A file to hold the serialized session working memory data without the rulebase."
  (io/file "working-memory-file.dat"))

;;;; Serializing only the rulebase of a session (not the working memory).

(with-open [os (io/output-stream rulebase-file)]
  (d/serialize-rulebase fired-session
                        (df/create-session-serializer os)))

(def deserialized-rulebase
  (with-open [is (io/input-stream rulebase-file)]
    (d/deserialize-rulebase (df/create-session-serializer is))))

;;;; Serializing only the working memory of the session (not the rulebase).

(def wm-serializer (->LocalMemorySerializer (atom nil)))

(with-open [os (io/output-stream working-memory-file)]
  (d/serialize-session-state fired-session
                             (df/create-session-serializer os)
                             wm-serializer))
(def deserialized-session
  (with-open [is (io/input-stream working-memory-file)]
    (d/deserialize-session-state (df/create-session-serializer is)
                                 wm-serializer
                                 ;; NOTE!! The deserialization needs a rulebase to attach the working
                                 ;; memory to to fully restore the session.  They were stored separately
                                 ;; in this example.
                                 {:base-rulebase deserialized-rulebase})))

{% endhighlight %}

This example is the same as before, except the session rulebase and working memory are serialized separately.  This is commonly a very useful feature.  It is often the case that a "base" session is created that constructs a rulebase (Rete-based rule/query graph).  This base session is then used for mutually exclusive working memory datasets.  This may be useful, for example, in a situation where there was per "user" domain data that was to be processed separately against the same set of rules.  For large sets of rules, the rulebase can take non-trivial amounts of space and time to serialize and to deserialize.  If the rulebase can be shared among different working memory states, Clara durability allows it to be stored separately.  When deserializing the working memory state to recreate a deserialized session, the deserialized rulebase has to be provided via the `:base-rulebase` option passed to `d/deserialize-session-state` above.

### Implementing the d/IWorkingMemorySerializer protocol ###

As stated previously, Clara currently provides a default implementation of the `d/ISessionSerializer` that uses [Fressian](https://github.com/clojure/data.fressian), but it does not currently provide a default implementation for the `d/IWorkingMemorySerializer`

The reason for this is that the `d/ISessionSerializer` is responsible for serializing and for deserializing the actual rulebase (Rete-based) graph representation.  This is really an implementation detail of Clara.  Any implementor of this protocol is going to become necessarily coupled to quite a few internal details of this graph structure.  Also, this structure is fully within the domain of Clara rules itself.  This makes it reasonable, and perhaps necessary, for Clara to maintain an efficient implementation of this protocol (and in the future possibly more implementations).  Most consumers are expected to directly use the provided implementation(s).

The `d/IWorkingMemorySerializer` protocol is different.  It is responsible for serializing and for deserializing the state of the user-defined facts from a domain unknown to Clara rules itself.  If the domain of facts happens to be Clojure datatypes that are supported by Fressian and Clara's `clara.rules.durability.fressian` custom Fressian handlers, it may be reasonable to offer this as a default implementation from Clara that could optionally be used by consumers.  This may happen in the future.

However, in general, it is difficult to provide a suitable serialization protocol for user-defined facts, since these facts can have arbitrary datatypes and structures.  If the rules are being used in a more traditional Java ecosystem, the facts could be [Java beans](https://docs.oracle.com/javase/tutorial/javabeans/) that might be best serialized via [Java serialization](https://docs.oracle.com/javase/8/docs/technotes/guides/serialization/).  In a Hadoop ecosystem, the facts could also be something like [Avro records](https://avro.apache.org/) that have their own specific serialization format.  There are many more domains in which facts may come from.  Each domain will likely have a serialization framework that is a better fit than others.  Efficient serialization and deserialization of facts can be a crucial concern when it comes to performance of the Clara durability functionality.

The Clara durability layer will only pass distinct object references (based on object identity, i.e. distinct by `identical?`) as facts to the `d/serialize-facts` function of the `d/IWorkingMemorySerializer` protocol implementation.  This helps the implementor avoid serializing the same facts multiple times.  However, it is possible for facts to have references to other facts that are returned.  Also, accumulators can produce arbitrary data structures and aggregates that may contain references to other returned facts.  So the implementor of the `d/IWorkingMemorySerializer` protocol must still deal with the efficient and appropriate serialization of multiple references to the same object.  Some serialization frameworks handle this automatically, others do not.

For details on implementing this protocol, [refer to the docs here]({{site.clojuredoc}}clara.rules.durability.html#var-IWorkingMemorySerializer).
