# Groupby Inc: SRE Image Resize Exercise

This repo contains notes, thoughts and elements of a possible solution to the
SRE Image Resize Exercise from Groupby Inc. Here's a quick recap.

## Exercise description

### Background
Our fellow development colleague Osama is swamped with a tedious and manual
task and needs our help. You see Osama had been assigned to add a watermark on
a DSLR image and serve it in as many formats (width, height, quality) as he can,
depending on Osama’s mood he misses some sizes just to cut corners in order to
deliver on time and SRE observability has noted missing images on the frontend.
When confronted Osama threw up his hands and said, “I hate this toil”. Needless
to say SRE told him, “we got this”. As SRE’s, we need to keep scalability and
simplicity in mind. So before SRE serves the image they must resize it. So all
Osama has to do is upload his image and maybe watermark it?(or can we do this
too). Currently it is being served from a storage bucket with a bunch of images.

### What we need you to do
Build a solution to resize the image in realtime and also include a watermark
that is your name. How you do that is up to you.

The url format is

```
https://ZONE/resizer/image/OPTIONS/SOURCE-OF-IMAGE
```

Options are:

```
A comma-separated list of options such as width, height, and quality.
```

It might look like this In HTML.

```html
<img src="/resizer/image/width=80,quality=75/https://s3.example.com/bucket/image.png">
```

Important Considerations:
- How do you know if your solution works, scales, and is monitored?
- How are you going to teach Osama how to use the solution, does he even need
  to do anything else other than to upload?
- How are you ensuring teams using your solution get the latest version of your
  application?

Deliverables:
1.  Design, architect and test an end to end solution that works for 10 RPS -
    100,000 RPS. Show some load tests, or what you expect the load test to look
    like when we run it.
2.  Return the project folder in Gitlab / GitHub / Bitbucket repo.
3.  Include instructions on how you would deploy this so it scales across many
    Kubernetes clusters for high availability if at all and any mechanisms you
    might leverage to solve it without deploying anything at all.
4.  Include what you think the cost to run this app will be at 10 RPS vs 100,000
    RPS.
5.  Please provide a descriptive project README (Markdown format preferred),
    presenting the various steps you took while designing and implementing the
    solution. Some diagrams would be nice, but not mandatory.
6.  Include any links to external sources you may use (i.e stackoverflow, books,
    old code).

---

## My solution

Each of the relevant deliverables above has a corresponding markdown file where
you'll find a text explanation providing relevant information. The code
contained in this repo is meant as a proof of concept but could serve as a
working solution in local enviroments or could be deployed to production with
some modification (see [DEPLOYMENT_INSTRUCTIONS](DEPLOYMENT_INSTRUCTIONS.md)
for details).

Deliverables documentation:
1.  SOLUTION.md
2.  N/A
3.  DEPLOYMENT_INSTRUCTIONS.md
4.  COST_PROJECTION.md
5.  STEPS_TAKEN.md
6.  EXTERNAL_SOURCES.md

To run locally, first run the watermarking script (watermark_image.sh), then
build the docker image. Currently, there is only one example image, images.jpg,
so when the docker container is running, test the resizer by opening a browser
and visiting:
```
http://localhost:<PORT>/resizer/image/width=<WIDTH>,height=<HEIGHT>,quality=<QUALITY>/https://s3.example.com/bucket/image.jpg
```
