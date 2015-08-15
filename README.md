
WebHook Receiver
================

This repository contains an application for receiving WebHook events from various services (currently github & bitbucket),
which is written in perl and uses [Mojolicious::Lite](http://mojolicio.us/perldoc/Mojolicious/Lite).

Overview
--------

The code in this repository is designed to listen and respond to "webhooks" posted by various git-hosting services.

Currently we support:

* [Github](http://github.com/)
* [BitBucket](http://bitbucket.com/)

When hooks are received the ultimate goal is to get the location of the source repository, which will be "`https://github.com/user/repo`", "`http://bitbucket.org/user/repo.git`", or similar.

In this codebase very little processing happens in the webhook receiver, instead the goal is to extract the repository URL and add it to a local queue for later processing.  (Because if your webhook takes "too long" to run the remote side will decide it has failed, which would be bad.)



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
