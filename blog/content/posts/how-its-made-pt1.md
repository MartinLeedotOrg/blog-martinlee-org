---
title: "How It's Made Pt1"
date: 2017-09-16T09:00:00+01:00
draft: false
---

### Intro
First thing first, we're going to need some infrastructure to host the blog. I've decided to over-engineer this because I enjoy that sort of thing. I'm going to host it entirely in AWS, and as a static site (think Hugo, Jekyll, etc.) By the time your reading this - I'll have made a decision on what to use, but this post was drafted while I was still deciding.

#### Components:
 * S3 Bucket to host the static blog
 * CloudFront Distribution to serve the blog over HTTPS
 * Route53 Alias record to point `blog.martinlee.org` at the CloudFront Distribution

#### Tools:
 * [awscli](https://aws.amazon.com/cli/)
 * [terraform](https://www.terraform.io)

### Setup
We'll use terraform to generate everything. I've uploaded my terraform files to [GitHub](https://github.com/MartinLeedotOrg/blog-martinlee-org/tree/master/infra).

For small scale projects I like to store my terraform state in S3, so first we'll need a bucket for that:  
```aws s3api create-bucket terraform-conf-bucket```

You'll need to specify a globally unique bucket name.

We'll also need an SSL cert for the CloudFront distribution, luckily AWS gives us one for free:  
`aws acm request-certificate --region us-east-1 --domain-name www.martinlee.org`

You'll need to do this in us-east-1 so that CloudFront can get your certificate.

That command will return the ARN for the certificate, but for it to become active you'll first need to [validate domain ownership](http://docs.aws.amazon.com/acm/latest/userguide/gs-acm-validate.html)

My setup assumes you're using Route53 for your hosted zone. If not, you can use a CNAME (as long as you don't plan on using the root domain)

#### backend.tf
This stores the terraform state in an S3 bucket. This is important to keep safe - lose it and you'll find it very difficult to use terraform to modify your infrastructure again. If you'd like, you can skip this step and simply keep your state in source control, but I'd recommend against it.

#### website.tf
A quick read through this should make it fairly clear what's happening, no real magic going on.  There are some gotchas in the `aws_cloudfront_distribution` - you'll want to set `price_class` appropriately.

Here I've used `ssl_support_method = "sni-only"`.  This means we can take advantage of SNI to allow CloudFront to serve our website from a shared IP. One the one hand, we won't be able to serve content to [older devices](https://en.wikipedia.org/wiki/Server_Name_Indication#Support) (Android before 4.x, IE on XP, etc.) but on the other it'll save us [$600/mo](https://aws.amazon.com/cloudfront/custom-ssl-domains/)

#### Execution
 * `terraform init`
   * Set up the terraform environment, download the required plugins and initialize the backend.
 * `terraform plan`
   * See what terraform's about to try.
 * `terraform apply`
   * Do the thing.
 * `terraform delete`
   * Tear everything down if you'd like.

The CloudFront distribution will take some time to deploy.  You can check on its progress with `aws cloudfront get-distribution --id=distribution-id`.

```
$ while true; do aws cloudfront get-distribution --id=distribution-id | grep Status; sleep 5; done
        "Status": "InProgress", 
        "Status": "InProgress", 
        "Status": "InProgress", 
...
...
        "Status": "InProgress", 
        "Status": "InProgress", 
        "Status": "Deployed", 
        "Status": "Deployed", 
        "Status": "Deployed", 
```

### Outro
That's it! We're done. What we could have done with a site builder in five minutes, we've spent an hour on.

I'll make another post in the future once I have an idea of how much this is costing me, but I'm going to ballpark it at a few dollars per month.

I've made a [Part 2](/posts/how-its-made-pt2-or-hugo-in-s3-and-cloudfront/) where I cover how I deploy a hugo static site to this setup.