---
title: "Rancher Hosts in an EC2 Private Subnet"
date: 2017-11-07T12:12:10Z
draft: false
---

### Intro

Just a quick post with an EC2 launch configuration for running a Rancher Host in an EC2 Private Subnet.

Doing it this way will let you set up autoscaling groups etc. This also provides an alternative to using docker-machine across private IPs, this way we don't have to set up any private SSH communication between the Rancher Server and the Host, which may (should?) exist in different networks.

Super simple stuff, but I've not seen much online in terms of how people are implementing Rancher and would like to slowly add to that.

### Launch Configuration

The important thing here is to set `User data` (under `Advanced Details` at the `Configure details` stage) like so:
```
#!/bin/bash
curl https://releases.rancher.com/install-docker/17.06.sh | sh
docker run -e CATTLE_AGENT_IP="$(curl http://169.254.169.254/latest/meta-data/local-ipv4)"  --rm --privileged -v /var/run/docker.sock:/var/run/docker.sock -v /var/lib/rancher:/var/lib/rancher rancher/agent:v1.2.6 https://rancher.example.com/v1/scripts/_CHANGE_THIS_BIT_
```

This will:

  * Install a supported version of Docker
  * Register the host with the *Private IP* against your rancher instance.

### Other bits

You'll need to set up a security group, just make sure your hosts can talk to each other on `UDP/500` and `UDP/4500`.

You'll also need some way for these Rancher Hosts to access the internet, like a NAT Gateway, or an alternative method of getting everything they need.