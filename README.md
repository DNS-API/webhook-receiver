WebHook Receiver
================

The code in this repository is designed to listen and respond to webhook-events posted by various git-hosting services, and it is written using the [Mojolicious::Lite](http://mojolicio.us/perldoc/Mojolicious/Lite) framework.

Currently we support receiving webhooks from the following sites:

* [Github](http://github.com/)
* [BitBucket](http://bitbucket.com/)

When an incoming webhook-event is received the ultimate goal is to parse it, identify it, and extract the URL of the git repository from which it was sent.  For example the repository might be:

* `https://bitbucket.org/skx/dns`.
* `git@github.com:skx/private-dns.git`.
* `git@bitbucket.org:/skx/some-local-dns/`.
* ...

In this codebase very little processing happens in the webhook receiver, once the repository URL is identified it is merely added to a queue, where it can be processed by something else.  This pattern is useful because if a webhook-request takes too long to complete the sender might decide we've failed and retry it.


Motivation
----------

The [DNS-API.com](https://dns-api.com/) service is designed to trigger DNS updates when a public git repository receives updates.

In order to do this it must be notified when the repository has changed, and this is achieved by asking users to configure a webhook.

The flow of execution goes something like this:

* The user pushes their code to the hosting-service.
    * i.e. They run "`git push`" to push their code to github.
* The hosting service initiates a HTTP-POST to our webhook-service.
    * i.e. Github initiates makes a HTTP POST-request containing details of the most recent commit.
* The webhook-service must parse the repository URL from the submission.
    * i.e. This code runs and determines the originating repository.
* Once parsed the details are stored in a queue.
    * A separate non-public component then runs.


Plugins
-------

In the past this repository contained a monolithic service, written in Ruby, which handled all the actions.  This was hard to test, and harder still to update for new services.  With that in mind it was reworked, from-scratch, to have a Plugin-based architecture.

Each of the plugins beneath the `WebHook::Plugin::` namespace are loaded when the server starts, and three distinct plugin-types are recognized:

* Those that implement `identify`.
   * These are shown the webhook body, and allowed the opportunity to parse and recognize it.
   * e.g. `WebHook::Plugin::Parser::GitHub`.
* Those that implement `validate`.
   * These exist just to determine whether the webhook reached us via a valid end-point.
   * e.g .`WebHook::Plugin::Validate::User`.
* Those that implement `enqueue`.
   * Once a successful identification has occurred the enqueue plugins will save the result away.
   * e.g. `WebHook::Plugin::Queue::Redis`.

To add support for a new hosting service it should be sufficient to create a new plugin, implement the `identify` method to return the URL of the repository, and restart-the service.


Installation
-------------

On a Debian GNU/Linux system:

    # apt-get install libmojolicious-perl libredis-perl

Once you've installed one of the gems launch the service via:

    ./webhook-receiver

* **Notes**
   * You should also ensure you have a `redis` server running on the localhost.
   * You don't need to run the service as root, as it binds to a high-port (`9898`).


Testing
-------

Testing can be achieved by firing off pre-cooked queries ("`./test-driver`"), or via the bundled test-cases ( "`make test`").


Steve
---
