---
title: "How Its Made Pt3"
date: 2019-05-22T18:45:44+01:00
draft: false
---


### Intro

In [Part 2](/posts/how-its-made-pt2-or-hugo-in-s3-and-cloudfront/) I showed you how I used a makefile to deploy to aws, taking advantage of S3 and CloudFront. I mentioned I'd like to add a little CI/CD

### Adding CI/CD

Enter [netlify](https://www.netlify.com). It took 15 minutes to get set up and it's free.  I'm not sure I need to add much more in this paragraph - their documentation is awesome.

It's one or two less things to think about and it means I can divert my efforts elsewhere. It's perhaps a little slower than my old makefile, but it does mean that I can deploy from practically anywhere and don't have to think about AWS credentials.


### The Future
I don't know! Maybe write more?