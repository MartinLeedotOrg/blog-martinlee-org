---
title: "NFS for Rancher in Google Cloud Platform"
date: 2017-09-17T18:14:39+01:00
draft: false
---

### Intro

Recently, I deployed some Rancher hosts in Google Cloud Platform, taking advantage of some free credit.

I've been spoiled by Rancher's integration with Amazon Web Services EFS and EBS - making storage for containers very simple. GCP doesn't yet have a similar integration so I had to find another way.

#### File Servers on Google Compute Engine

Google offer some [possible solutions](https://cloud.google.com/solutions/filers-on-compute-engine) in their documentation. I chose to go with the Single Node File Server. This doesn't have the performance or fault tolerance of some solutions, but I'm completely confident putting log files on it, and even config files for non-essential workloads. We don't quite get the easy of use of AWS EFS, but it is the next best thing.

#### Steps to take in GCP

 * Start a `singlefs` instance from [Google Cloud Launcher](https://console.cloud.google.com/launcher/details/click-to-deploy-images/singlefs)

Easy enough, just follow the prompts to specify a file server for the performance and capacity you need.

 * Modify `/etc/exports`

I bumped into [rancher issue #7334](https://github.com/rancher/rancher/issues/7334) immediately. My `/etc/exports` file now looks like this:  
```
/data 10.0.0.0/8(no_root_squash,rw,no_subtree_check,fsid=100)
/data 127.0.0.1(rw,no_subtree_check,fsid=100)
```

I then restarted the nfs service:  
`sudo service nfs-kernel-server restart`

#### Steps to take in Rancher

 * From the Catalog, install `Rancher NFS`

 * Add a volume to a container!
 ![Add a volume](/images/rancher-nfs-volume.png)

#### Check it works

You should now be in a place where you can create files in the volume and have that change reflected in the NFS share.  You could check this by having a look in the directory in the singlefs vm (check `/data/volumename`).