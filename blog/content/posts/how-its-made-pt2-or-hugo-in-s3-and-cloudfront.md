---
title: "How Its Made Pt2 or Hugo in S3 and CloudFront"
date: 2017-09-17T18:56:42+01:00
draft: false
---

### Intro

In [Part 1](posts/how-its-made-pt1/) I built my architecture using Route53, S3 and CloudFront. This would suit pretty much any static site, but I chose to use [Hugo](https://gohugo.io). Why? I hadn't used it before...

### Bringing it all together

Go back and read the [first part](posts/how-its-made-pt1/) for how to get yourself a place where you can put static HTML in S3, and then serve it over a CDN with HTTPS through CloudFront - all without using the GUI!

Then have a look at Hugo's [Quick Start](https://gohugo.io/getting-started/quick-start/) guide.

Now we just need a way to take the blog posts and put them in the bucket!

I'm a big fan of Makefiles, so I decided that was the way to go. You can see it with everything else in my [GitHub Repo](https://github.com/MartinLeedotOrg/blog-martinlee-org), but it looks something like:  
```
build:
	cd ./blog && hugo -t hugo_theme_pickles

deploy: build
	aws s3 sync ./blog/public/ s3://blog-martinlee-org/

dev:
	cd ./blog && hugo server -t hugo_theme_pickles -w -D

invalid:
	aws cloudfront create-invalidation --distribution-id E734L0F2WYJ6 --paths /posts/* / /index.html
```

Worth noting - the indentation _must_ be tabs, not spaces.

Now, I can run `make dev` to see the post on my local machine while I'm making a draft, and then `make deploy` to put that on the internet. I could in future extend it to implement a `make draft` to put draft posts somewhere for people to proof-read.

It's worth understanding CloudFront's Cache Invalidation. AWS provide 1000 free invalidations per month, but after that they cost $0.005 per invalidation path. I did briefly consider putting invalidations in the deploy stage, but decided I'd rather it was a more conscious decision.

### The Future
So far it's working nicely, and I can put blog posts on the internet practically as fast as I can write Markdown [^1]. I like not having to use a CMS and I love the speed of a static site. I could make it a bit more flexible in future by integrating a CI/CD system like [CircleCI](https://circleci.com/blog/build-test-deploy-hugo-sites/) - allowing me to simply do a Git commit from anywhere, so that'll probably feature in the near future.


[^1]:
```
$ time make deploy
cd ./blog && hugo -t hugo_theme_pickles
aws s3 sync ./blog/public/ s3://blog-martinlee-org/
...
real	0m1.701s
user	0m0.613s
sys	0m0.152s
```
