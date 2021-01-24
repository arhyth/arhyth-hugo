---
title: "crash looping pod"
date: 2021-01-24T19:26:51+08:00
draft: false
---

## The case of the crash looping pod

A few weeks ago at work we launched a new microservice which I had the opportunity to solely implement. Aside from some deserialization issues (an external API dependency with inconsistently typed response fields), everything seemed to be OK. Then it wasn't. Our alerting system in GCP (Google Cloud) was on fire only hours after we went live.

The pods were on a crash loop. And there were no logged errors on Stackdriver.

I added all sorts of error logging and a few `recover()` in critical places. (Yes. This would probably be less painful if we had distributed tracing in place. We make do.) But still, there was nothing. There was something curious though, the `info` logs for inbound requests did not match the outbound requests. The crash involved only one endpoint that accepts an array, among other fields, and for each of the items in the array, the service makes one external call. Initially, I attributed this to the crash dropping the other calls and assumed it to also be the case for the "missing" `error` logs. I eventually learned this assumption to be incorrect. There were really no error logs because there were no errors.

We found a hint in the `events` tab of the corresponding Kubernetes workload in GCP console. The workload would fail a `healthcheck`probe before a "crash". This was tricky to catch because Kubernetes events are stored in the apiserver and by default are not persisted and kept only for an hour. You might have already noticed I enclosed "crash" in double quotes. We didn't immediately realize what was happening to the pods. I had correctly implemented and exposed the healthcheck endpoint. We could call it just fine. We left it as is for a day or two since the crashes were not really business critical and we were also out of ideas.

Then we discovered the latency problem. On requests with very big arrays previously mentioned, the latency spikes were much higher than other services usual response times. This led me to another discovery. The response time for the healthcheck endpoint would range north of 1s when the request is made concurrent to a "big array" request. A usual response time for a healthcheck probe would only range in the order of 10ms to 100ms. In short, "big array" requests were starving healthcheck probes. This was the lightbulb moment. So I asked what are default GKE/Kubernetes timeout config, if any. I then learned that in Kubernetes by default workloads have a healthcheck probe timeout of 1s and a retry of 3. Failing this, the scheduler would garbage collect the "unhealthy" pod and deploy a fresh instance. Thus the crash loop.

Bumping resource limits and timeout up a few solved this.

