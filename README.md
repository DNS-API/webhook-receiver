
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



