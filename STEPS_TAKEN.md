# Steps taken

### 1.  Research and planning

I began by trying to come up with as many possible solutions as I could, from
my own ideas or from resources online. Then I evaluated the viability,
strengths and weaknesses of each approach. After all of that, I chose an option
and began planning how I would implement it.

See notes below.

### 2. Implementation

After settling on an approach, I began by writing the NGINX configuration. Then
I created the Dockerfile and got a working re-sizing service running. Finally I
created a script to watermark images just to show how they would finally look in
a complete version.

---

## Research and planning notes

> # Groupby Inc: SRE Image Resize Exercise
> 
> ## Option 1:
> 
> ### Overall approach:
> 
> Pre-process and store all required image versions.
> 
> As soon as image is uploaded, all required watermarked and resized versions are
> automatically generated and stored in storage buckets. If possible, bucket
> paths would match url format currently in use, or if such paths would not be
> permitted, buckets would use some other url format and urls in code would be
> remapped during build with webpack, vite, npm script, etc.
> 
> ### Advantages:
> 
> 1.  Minimal compute costs for limited set of options. Images are only ever
>     processed one time, so whether relying on a third-party service or in-house
>     implementation, costs are bounded by total volume of all images *uploaded*
>     rather than all images *requested*.
> 
> 2.  Efficient. Since processing work is not duplicated, uses minimal compute
>     resources. Also, since images are stored as static files, can make use of
>     compression and CDN/caching, meaning, again, lower cost, but also massive
>     scalability and minimal latency.
> 
> 3.  Simple design and setup. Developers don't need to do much. They may have to
>     write one script to remap urls. Otherwise all they do is upload the image
>     file as usual. SRE similarly just needs to create a service to watch for
>     upload events and generate and store processed images. No need for special
>     handling of client requests. Scalability concerns are offloaded to CDN.
> 
> 4.  Separate concerns. Since image processing, storing and caching are all
>     independent, solution can be easily adapted to suit any image processing
>     system, storage provider or CDN with minimal reconfiguration.
> 
> ### Issues:
> 
> 1.  Potentially huge number of images. According to Sarim, width and height are
>     in pixels (so integers only) and quality is a measure of file size (in range
>     1-100) which can be ignored. If we assume a lowerbound of 1 (silly, maybe,
>     but do not have information to rule it out) and an upperbound of, say, 1000
>     pixels for both height and width, the service would need to generate and
>     store 1,000,000 images for every uploaded file. This would appear untenable.
> 
> 2.  Increased use of storage bucket. Even if a more limited set of options is
>     sufficient, will still increase storage capacity used by some multiple of
>     uploaded images and even with caching, will have increased egress traffic
>     from storage service.
> 
> 3.  Requires active re-formatting if needs change. If there were a sufficiently
>     small set of options to use this approach, if the requirements of those
>     options ever changed, we would need to re-format all images to meet the new
>     requirements.
> 
> 4.  Failure detection and recovery.
>     Possible points of failure:
>     - generation: ensure all required images are created (post-hoc script)
>     - storage: ensure all images continue to exist (alert on large number of
>        errors on pertinent requests) and are correct (?)
> 
> ---
> 
> ## Option 2:
> 
> ### Overall approach:
> 
> Process images as needed with standalone service.
> 
> Developers upload images to storage bucket as usual. No new image versions are
> immediately generated or stored. Requests are received by image store (static
> file server?). If matching image version is found (cache?), returns image. If
> not, redirects to image processing service which generates image, uploads to
> storage bucket, then redirects back to store.
> 
> ### Advantages:
> 
> 1.  Cheap to run with *any* number of different options. Since any missing
>     images will always be generated when requested, can store forever and never
>     re-process or can automatically delete with bucket policy to reduce storage
>     costs allowing us to tune behavior to minimize costs.
> 
> 2.  Efficient. All the efficiency benefits of option 1 with the added bonus that
>     now there is no need to generate any image that may never be used or to
>     store an image for an extended period if that may image be rarely used.
> 
> 3.  Simple to use. Developers don't need to do anything apart from upload the
>     image file as usual.
> 
> 4.  Separate services. Same as option 1.
> 
> 5.  More fault-tolerant. If images are not created or are deleted, generator
>     will create new ones as needed.
> 
> 
> ### Issues:
> 
> 1.  Added architectural complexity. Creates need for:
>     - Handling image requests differently from other static files
>     - Redirect logic for missing images
>     - Highly available service to process images on-demand
>     - Access to images that are created after startup for service handling
>       original image request
>     - Possibly even some way to identify un-trusted requests (it would be a
>       silly attack but vandalism does exist)
> 
> 2.  Failure detection and recovery.
>     Possible points of failure:
>     - generation: ensure image generator always successfully creates and uploads
>       image or sends error response to client, otherwise client may loop forever
>     - storage: Must ensure that generated images are stored as expected
> 
> ---
> 
> ## Option 3:
> 
> ### Overall approach:
> 
> Process and serve images as needed with static file server.
> 
> Developers upload images to storage bucket as usual. Requests are directed to
> static file server, which checks cache for existing version. If not found,
> retrieves file from bucket, resizes, caches and returns. No need for any
> additional service.
> 
> ### Advantages:
> 
> 1.  Cheap...likely cheaper than any other option. Storage costs would only be
>     for the original files: no need to store resized images. Network costs would
>     be minimal, compute costs would only be for the cpu and memory usage of a
>     very efficient kubernetes service.
> 
> 2.  Efficient. A good file server should be tough to beat.
> 
> 3.  Dead simple. One bucket. One static file server that can be configured once
>     and deployed across any number of k8s clusters.
> 
> 4.  Fault tolerant. Resized images are created and cached as needed, so only way
>     one becomes unavailable is if the original is missing or the bucket is
>     unreachable.
> 
> 5.  Easy to maintain and modify. Updating service will automatically update both
>     image processing and cached images once deployed. Can also modify relatively
>     easily to option #2 if one desires to handle image processing separately.
> 
> ### Issues:
> 
> 1.  Watermarking support seems to be lacking in NGINX. Existing modules appear
>     to be little used, infrequently updated and troublesome to install. Must
>     choose between:
>       - Use existing watermarking module. Not great, as explained above.
>       - Watermark before upload to bucket. Implementation details depend on
>         how developers usually upload images. If done manually, could create a
>         script that does both the watermarking and the upload. If done in
>         build pipeline, could watermark there, too.
>       - Watermark automatically on upload. Would require supporting system like
>         Pub/Sub or Workflow triggering Cloud Run or Cloud Function.
> 
> ---
> 
> ## Option 4:
> 
> ### Overall approach:
> 
> Process and serve images as needed with third-party service (e.g. Cloudflare).
> 
> Developers upload images to storage bucket as usual, but image urls may need to
> be permanently modified. Third-party service handles both image processing and
> caching.
> 
> ### Advantages:
> 
> 1.  Efficient. With a good CDN, should be extremely fast and scalable.
> 
> 2.  Simple. Developers may need to make aforementioned url changes, otherwise
>     most setup should just be signing up for the service and configuring options
>     in the vendor UI.
> 
> 3.  Reliable. Should be, but see note below.
> 
> ### Issues:
> 
> 1.  Maintainability. Likely will not be able to track configuration changes in
>     git.
> 
> 2.  Observability. CDN may sit outside the scope of typical metrics.
> 
> 3.  Vendor dependence. Moving to a different vendor may change configuration and
>     behavior.
> 
> 4.  Bundled services. Caching and processing are now handled by the same entity,
>     so may not be able to change one without changing the other.
> 
> 5.  Failure detection and recovery not applicable (see notes).
> 
> ### Notes:
> 
> 1.  Cost unknown. Could be cheap. May depend on vendor. But since we no longer
>     handle anything other than storing the original files, storage costs are
>     minimal and network and compute costs are 0.
> 
> 2.  Moving responsibility from our system to a third-party cuts both ways. We no
>     longer have to invest as much time and effort making the system robust,
>     efficient and scalable, but we also don't have a way to fix things if
>     something goes wrong. Good CDNs typically have a reputation for reliability,
>     but [things can still go
>     wrong](https://www.theregister.com/2023/11/07/cloudflare_datacenter_outage/).
> 
