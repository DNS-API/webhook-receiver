
WebHook Receiver
================

This repository contains a [sinatra](http://sinatrarb.com/)-based service which will respond to
"webhook events".


Overview
--------

The code in this repository is designed to listen and respond to "webhooks"
posted by various git-hosting services.

Currently we support:

* [Github](http://github.com/)
* [BitBucket](http://bitbucket.com/)

When hooks are received the ultimate goal is to get the location of
the source repository, which will be "`https://github.com/user/repo`",
"`http://bitbucket.org/user/repo.git`", or similar.

In this codebase very little processing happens in the webhook receiver,
instead the goal is to extract the repository URL and add it to a local
queue for later processing.  (Because if your webhook takes "too long" to
run the remote side will decide it has failed, which would be bad.)



Motivation
----------

The [DNS-API.com](https://dns-api.com/) service is designed to trigger DNS
updates when a public git repository receives updates.

In order to do this it must be notified when the repository has changed,
and this is achieved by asking users to configure a webhook.

The flow of execution goes something like this:

* The user pushes their code to the hosting-service.
    * i.e. They run "`git push`" to push their code to github.
* The hosting service initiates a HTTP-POST to our webhook-service.
    * i.e. Github initiates makes a HTTP-request containing details of the most recent commit.
* The webhook-service must parse the repository URL from the submission.
    * i.e. This code runs and determines the originating repository.
* Once parsed the details are stored in a queue.
    * A seperate non-public component then runs.



Installation
-------------

On a Debian GNU/Linux system:

    # apt-get install ruby rubygems
    # gem install redis

Once installed launch via:

    ./webhook-receiver.rb --debug

>**NOTE**: Don't run this as root, you don't need to and it is a bad idea.


Testing
-------

Testing can be achieved by firing off pre-cooked queries ("`./test-driver`"), or via the bundled test-cases ( "`make test`").


Steve
---
