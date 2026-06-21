---
title: "Staleus"
description: "Breaking AMD SEV-SNP via Memory Incoherence"
summary: "Staleus: Breaking AMD SEV-SNP via Memory Incoherence"
date: 2025-01-16T00:04:48+02:00
lastmod: 2025-01-16T00:04:48+02:00
draft: false
menu:
  docs:
    parent: ""
    identifier: "staleus"
weight: 810
toc: true
seo:
  title: "Staleus | XCA" # custom title (optional)
  description: "Breaking AMD SEV-SNP via Memory Incoherence " # custom description (recommended)
  canonical: "" # custom canonical URL (optional)
  noindex: false # false (default) or true
---
<link rel="stylesheet" href="/img-theme.css">
<div class='text-center' style='padding-bottom: 3rem;'>
<div>
   <img src="/staleus-symbol.svg" class='' style='margin-top: 3rem; margin-bottom: 1rem; height: 250px; width: auto;'>
</div>
<h1 class='h1'>Staleus</h1>
<p class="lead">Breaking AMD SEV-SNP via Memory Incoherence</br> (<a href='https://www.usenix.org/conference/usenixsecurity26'>USENIX Security 2026</a>)</p>
<div class="row justify-content-center">
  <div class="col-lg-5 col-sm-6  text-center" style="margin-top: 1.2rem">
    <div class="d-flex flex-column flex-sm-row w-100 text-center">
      <a class="btn btn-primary btn-cta rounded-pill btn-lg head-button" href="/staleus/staleus_usenix26.pdf" role="button">Paper</a>
    </div>
  </div>
<div class="col-lg-5 col-sm-6  " style="margin-top: 1.2rem">
    <div class="d-flex flex-column flex-sm-row" >
      <a class="btn btn-primary btn-cta rounded-pill btn-lg head-button" href="https://zenodo.org/records/20787413" role="button">Source</a>
    </div>
  </div>
<div class="col-lg-5 col-sm-6  " style="margin-top: 1.2rem">
    <div class="d-flex flex-column flex-sm-row" >
      <a class="btn btn-primary btn-cta rounded-pill btn-lg head-button" href="#citation" role="button">Citation</a>
    </div>
 </div>
</div>
</div>



## Summary
Confidential computing allows cloud tenants to offload sensitive computations and data to remote resources without needing to trust the cloud service provider. Hardware-based trusted execution environments, like AMD SEV-SNP, achieve this by creating Confidential Virtual Machines (CVMs). With Staleus, we present a novel attack that induces memory incoherence between the secure co-processor (PSP) and x86 cores. By rendering the PSP memory incoherent, a malicious hypervisor can forge critical CVM metadata, enabling arbitrary read and write access within a fully attested CVM, completely breaking SEV-SNP security guarantees.

### What is AMD SEV-SNP?
Standard cloud environments expose tenant computation and data in use to potentially untrusted cloud service providers. Confidential computing addresses this by using Confidential Virtual Machines (CVMs): hardware-shielded environments that isolate active workloads and guarantee complete data privacy from the host. Secure Encrypted Virtualization-Secure Nested Paging (SEV-SNP) is an AMD hardware extension that enables CVMs on AMD server CPUs. Unlike Intel TDX or Arm CCA, AMD anchors its Root of Trust in a dedicated secure co-processor: the Platform Security Processor (PSP).

### What is Memory Coherence?
Modern heterogeneous computing platforms contain distinct components, CPU cores, I/O peripherals, and co-processors like the PSP. These components all share access to the same physical DRAM. Memory coherence ensures that every components sees a consistent view of memory, regardless of what data may be cached locally. Without coherence, one component could read stale data from DRAM while another holds a more recent version in its cache, leading to inconsistencies.

{{< theme-image
    light="./figures/coherence-light.svg"
    dark="./figures/coherence-dark.svg"
    alt="High level overview of the Staleus Attack"
    description="Memory coherence mechanism on AMD Zen platforms.">}}

AMD enforces coherence through Coherence Controllers as shown in Illustration 1. When any components issues a memory request, the Coherence Controller broadcasts probe requests to all caches to check whether they cache the target data. If any cache holds a more recent copy of the requested line, it supplies that data directly, keeping all components in sync.

### Staleus Overview
In the confidential computing threat model, the hypervisor is untrusted and potentially malicious. In Staleus, we identify that the platform exposes a security-critical configuration register. The configuration register controls the cache coherence attributes of PSP memory transactions. More importantly, we find that a malicious hypervisor can modify this register to assert the *NoSnoop* attribute on all PSP memory accesses, forcing the PSP to bypass cache snooping and read or write DRAM directly.

This allows the attacker to induce a split memory view: the PSP operates on stale DRAM data while x86 cores hold divergent, more recent values in their caches. Staleus exploits this divergence in two ways. First, when the PSP reads DRAM, it retrieves stale data that does not reflect recent x86 cache writes. Second, when the PSP writes to DRAM, a subsequent x86 cache eviction silently overwrites the PSP-committed data. We leverage these primitives to forge the Guest Context Page, a PSP-protected structure holding the CVM attestation report and GuestPolicy fields, enabling the hypervisor to activate debug mode on a production CVM and gain arbitrary read and write access to CVM memory.

{{< theme-video
    light="./animations/staleus-light-diagram.mp4"
    dark="./animations/staleus-dark-diagram.mp4"
    alt="High level overview of the Staleus Attack"
    description="PSP writes to DRAM, but the Coherency Controller does not ensure cache coherence. A subsequent cache flush overwrites PSP written data.">}}


### Attack Details
In more detail, AMD Zen CPUs employ so-called bridges that translate between different bus protocols. The SYSHUB is one such bridge and serves as AMD’s architectural gateway for integrating third-party IP blocks into the Data Fabric. Among other functions, it converts standard AXI transactions into AMD’s proprietary Scalable Data Port (SDP) bus protocol. Our reverse engineering efforts reveal that the SYSHUB services multiple clients, all of which interface via an internal crossbar. Crucially, the PSP functions as one of these clients whenever it initiates access to the Data Fabric (e.g., targeting x86 DRAM). The SYSHUB is responsible for translating PSP AXI signaling into compatible SDP signals. 
{{< theme-image
    light="./figures/axi-sdp-light.svg"
    dark="./figures/axi-sdp-dark.svg"
    alt="Simplified data path for PSP memory requests"
    description="Simplified data path for PSP memory requests.">}}

Illustration 3 visualizes this data flow from the PSP through the SYSHUB to the Data Fabric. Because the translation from AXI to SDP is not a one-to-one mapping, and given that data and control signals possess differing widths, the SYSHUB must aggregate specific AXI data lines or synthesize new SDP-specific signals. The configuration for the SYSHUB exposes control bits that define how the cache coherence attributes propagate to the SDP interface. Modifying this configuration alters the memory coherence properties of the PSP with respect to x86 DRAM. PSP memory requests tagged with the NoSnoop attribute result in the transactions ignoring dirty data in residing in x86 caches.


### Attack Complexity
Staleus operates as a software-only exploit with a 100% success probability. It does not require single-stepping, any specific code running inside the victim CVM, or physical access to the hardware.

## Affected Hardware
We confirmed the vulnerability on AMD Zen 4 and Zen 5 EPYC processors running SEV-SNP. The two specific CPU models evaluated are listed below.

| Generation | CPU        | Launched   |
|------------|------------|------------|
| Zen 4      | EPYC 9124  | 10/11/2022 |
| Zen 5      | EPYC 9135  | 10/10/2024 |

## FAQ

{{< details "Q: Does this attack have implications beyond SEV-SNP?" >}}
- Staleus exploits the SYSHUB bridge configuration to compromise the PSP's memory coherence. We have not studied the impact of the vulnerability beyond SEV-SNP.
{{< /details >}}

{{< details "Q: Does Staleus affect non-confidential VMs that I have in the cloud?" >}}
- No. Staleus assumes a malicious hypervisor operating within AMD's SEV-SNP threat model. In the non-confidential VM threat model, the hypervisor is considered trusted.
{{< /details >}}

{{< details "Q: What are the requirements for the attack?" >}}
- An attacker needs hypervisor privileges to successfully mount the Staleus attack.
{{< /details >}}

{{< details "Q: Is the attack scenario realistic?" >}}
- We operate in the threat model defined for AMD SEV-SNP. AMD explicitly distrusts the hypervisor, and confidential computing specifically aims to protect sensitive data from a potentially malicious cloud provider.
{{< /details >}}

{{< details "Q: Why the name Staleus?" >}}
- The attack forces the PSP to operate on *stale* DRAM data, bypassing fresh values held in x86 caches. Staleus derives from this core primitive.
{{< /details >}}

{{< details "Q: What was the response from AMD?" >}}
- AMD acknowledged the vulnerability and assigned CVE-2025-54509. You can find more information on their advisory page [https://www.amd.com/en/resources/product-security/bulletin/amd-sb-3039.html](https://www.amd.com/en/resources/product-security/bulletin/amd-sb-3039.html).
{{< /details >}}

{{< details "Q: Does this have implications on Arm CCA or Intel TDX?" >}}
- Staleus does not apply to Intel TDX or Arm CCA, as those architectures do not rely on the a co-processor like PSP as their root of trust.
{{< /details >}}

{{< details "Q: Does this attack apply to other versions of SEV (e.g., SEV-ES)?" >}}
- No. AMD SEV and SEV-ES do not guarantee guest integrity and are thereby widely considered insecure-by-design. For this reason, we did not evaluate our attack against SEV and SEV-ES.
{{< /details >}}

{{< details "Q: Why is Staleus an instance of the XCA attack class?" >}}
- Staleus misconfigures the Infinity Fabric interconnect, specifically the SYSHUB bridge, to break SEV-SNP security guarantees, making it an instance of the Interconnect Corruption Attack (XCA) family.
{{< /details >}}

{{< details "Q: How is Staleus different from Fabricked and BreakFAST?" >}}
- All three attacks are instances of the XCA family with three different root causes. In terms of attacker capabilities, Fabricked drops PSP writes by misrouting DRAM transactions. BreakFAST redirects PSP read/writes into the Control Fabric. Staleus does neither, it alters the *coherence attributes* of PSP transactions inducing a split memory view between the PSP and x86 cores without redirecting any transactions.
{{< /details >}}

## Authors
- [Benedict Schlüter](https://benschlueter.com/)
- [Shweta Shinde](https://shwetashinde.com)

## Responsible Disclosure
We informed AMD about the vulnerability in September 2025. AMD acknowledged the vulnerability and assigned CVE-2025-54509.

## CVE & AMD Response
AMD acknowledged the vulnerability to be in scope and issued an advisory. Staleus was assigned CVE-2025-54509.

## Citation
To cite our paper, please use the following BibTeX entry:

{{< citation >}}
@inproceedings{schlueter2026staleus,
  title={{Staleus: Breaking AMD SEV-SNP via Memory Incoherence}},
  author={Benedict Schlüter and Shweta Shinde},
  booktitle={35th USENIX Security Symposium (USENIX Security 26)},
  year={2026},
  month = aug,
  address = {Baltimore, MD},
  publisher = {USENIX Association},
}
{{< /citation >}}