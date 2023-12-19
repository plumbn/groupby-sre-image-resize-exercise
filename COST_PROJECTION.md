# Cost projection

> Include what you think the cost to run this app will be at 10 RPS vs 100,000
> RPS.

It's difficult to get a clear understanding of pricing for many services in GCP,
and in many cases, a large number of assumptions would need to be made to make
any kind of projection at all. So instead of an actual projection, this document
will focus on simply the cost dynamics as RPS increase with the deployment
approach described in
[DEPLOYMENT_INSTRUCTIONS](DEPLOYMENT_INSTRUCTIONS.md).

## Cloud Storage:
Storage fees would remain constant but network usage would increase. The end
result would depend on a number of factors including:
- the rate of cache hits/misses in the file server
- the percentage of network egress to another location
- average file size

## GKE:
Based on local testing, it would appear that, with a high cache hit rate,
100,000 RPS could be served with just a handful of pods, perhaps 3-5. This would
suggest the impact of increased requests on GKE compute costs could be minimal.
Increased network charges would likely apply.

## Cloud Functions:
Increased requests would not affect Cloud Functions. The function would always
run once per upload.
