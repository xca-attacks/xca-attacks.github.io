---
title: "BreakFAST"
description: "Confused Deputy Attack on Infinity Fabric to Break AMD SEV-SNP"
summary: ""
date: 2024-04-04T00:04:48+02:00
lastmod: 2024-04-04T00:04:48+02:00
draft: false
menu:
  docs:
    parent: ""
    identifier: "breakfast"
weight: 810
toc: true
seo:
  title: "BreakFAST | XCA" # custom title (optional)
  description: "Confused Deputy Attack on Infinity Fabric to Break AMD SEV-SNP" # custom description (recommended)
  canonical: "" # custom canonical URL (optional)
  noindex: false # false (default) or true
---

<link rel="stylesheet" href="/img-theme.css">

<div class='text-center' style='padding-bottom: 3rem;'>
<div>
   <img src="/BreakFast-symbol.svg" class='' style='margin-top: 2rem; margin-bottom: -1rem; width: 300px;'>
   <!-- <img src="/fabricked.png" class='w-10' style='margin-bottom: -1rem'> -->
</div>
<h1 class='h1'>BreakFAST</h1>
<p class="lead">Confused Deputy Attack on Infinity Fabric to Break AMD SEV-SNP <br/> (<a href='https://sp2026.ieee-security.org/'>IEEE S&P 2026</a>)</p>
<div class="row justify-content-center">
  <div class="col-lg-5 col-sm-6  text-center  go-button" style="margin-top: 1.2rem">
    <div class="d-flex flex-column flex-sm-row w-100 text-center">
      <a class="btn btn-primary btn-cta rounded-pill btn-lg head-button" href="/breakfast/breakfast_oakland26.pdf" role="button">Paper</a>
    </div>
  </div>
  <!-- <div class="col-lg-5 col-sm-6  go-button" style="margin-top: 1.2rem">
    <div class="d-flex flex-column flex-sm-row" >
      <a class="btn btn-primary btn-cta rounded-pill btn-lg head-button" href="https://github.com/xca-attacks/BreakFAST" role="button">Source</a>
    </div>
  </div> -->
<div class="col-lg-5 col-sm-6 go-button " style="margin-top: 1.2rem">
    <div class="d-flex flex-column flex-sm-row" >
      <a class="btn btn-primary btn-cta rounded-pill btn-lg head-button" href="#citation" role="button">Citation</a>
    </div>
 </div>
</div>
</div>

## Summary

Confidential computing enables cloud tenants to process sensitive data securely by isolating it from potentially untrusted cloud providers. Hardware-based trusted execution environments, like AMD Secure Encrypted Virtualization-Secure Nested Paging (SEV-SNP), achieve this by creating Confidential Virtual Machines (CVMs). AMD SEV-SNP relies on a trusted co-processor, the Platform Security Processor (PSP), as its hardware root of trust. The PSP programs critical configurations on the platform (e.g., access control rules and memory encryption keys).
With BreakFAST, we present a novel confused-deputy attack by misconfiguring the interconnect to trick the PSP into issuing privileged writes to sensitive platform configurations. We break AMD SEV-SNP with BreakFAST by forging cryptographic attestations and enabling debug mode on production-mode CVMs.

### What is AMD SEV-SNP?

Traditional cloud environments expose tenant computation and data to potentially untrusted cloud service providers. Confidential computing addresses this gap using CVMs: hardware-shielded environments that isolate workloads and enforce data confidentiality and integrity from the host. AMD offers confidential computing on server CPUs with a feature called AMD SEV-SNP.

### What is the Infinity Fabric?

The AMD System-on-Chip (SoC) connects components such as CPU cores, memory controllers, the PSP, and peripheral devices via a proprietary high-speed interconnect called the AMD Infinity Fabric. It introduces the notion of the Data Fabric, which is responsible for moving data between on-chip components.

The configuration of these data flows, equivalent of a control plane, is the responsibility of the System Management Network (SMN), also referred to as the Control Fabric within the Infinity Fabric. The Control Fabric is essentially a programmable configuration space. It maps configuration registers for each hardware unit on the SoC, such that different on-chip components can program the control plane by writing to the configuration space. For instance, the hypervisor accesses the Control Fabric for routine tasks, such as configuring specific components, e.g., audio controllers. As another example, the PSP programs memory encryption keys into the memory controller via the Control Fabric. Therefore, AMD strictly limits access to the Control Fabric. For example, the untrusted hypervisor is not allowed to write to the Control Fabric range that configures the memory controller or the IOMMU. Only the PSP, which is the root of trust, has the privilege to configure the entire Control Fabric.


### BreakFAST Overview

We show how an untrusted hypervisor can gain control over the Control Fabric.
Specifically, we trick the PSP (which has the appropriate privileges) into performing arbitrary Control Fabric reads and writes controlled by the hypervisor, which obviously breaks SEV-SNP.

The PSP can directly access the entire Control Fabric, which is a 4GB configuration space.
We reverse-engineer the platform and find that two on-chip components working in concert expose 1MB windows of the Control Fabric, thus providing an alternative means of accessing it.
Specifically, FASTREGCNTL sets the window position, while FASTREG maps accesses directly to the Control Fabric within that window.

However, the hypervisor lacks the privileges to configure FASTREGCNTL and therefore cannot control where the 1MB window points.
Even if the hypervisor could configure FASTREGCNTL, these accesses would still be subject to privilege checks that would stop it from making arbitrary changes to the Control Fabric.
To bypass these hurdles, we first mount a confused-deputy attack against the PSP to trick it into configuring the window position for us.
We achieve this by overlapping benign PSP accesses to DRAM with the location of FASTREGCNTL.
Next, we use the same primitive to trick the PSP into accessing FASTREG with attacker-controlled data.
As illustrated in Illustration 1, this confused-deputy primitive lets us read and write arbitrarily within the Control Fabric using PSP privileges.



{{< theme-video
    width="80%"
    light="./breakfast_video-light.mp4"
    dark="./breakfast_video-dark.mp4"
    alt="Overview of the BreakFAST Attack"
    description="The BreakFAST attack sequence: First, the attacker overlaps a benign PSP DRAM access with FASTREGCNTL to configure the window position within the Control Fabric. Then, a similar overlap with FASTREG tricks the PSP into performing arbitrary reads and writes to the Control Fabric via that window.">}}


Naturally, this breaks AMD SEV-SNP. We use the confused-deputy primitive to disable the IOMMU protection of CVM data. Once disabled, any DMA-capable device can access CVM memory freely. We demonstrate two end-to-end attacks: forging attestation and enabling debug mode on a victim CVM.

### What went wrong?
We identify two root causes that enable BreakFAST. First, the PSP violates the principle of least privilege: it propagates its privileged security attribute even for memory operations that do not require it. Second, the hypervisor can corrupt Infinity Fabric routing rules to trick the PSP into accessing on-chip components instead of DRAM.

### Attack Complexity
BreakFAST is a fully software-based exploit requiring no physical access and no prior knowledge of the victim CVM. It achieves 100% success for forging attestation and enabling debug mode.


## Affected Hardware
We confirmed BreakFAST on AMD Zen 4 (EPYC 9334) and Zen 5 (EPYC 9135) processors, both running SEV-SNP.


## FAQ
{{< details "Q: What does BreakFAST stand for?" >}}
  - The name captures how we break SEV-SNP using the FASTREG and FASTREGCNTL registers.
{{< /details >}}

{{< details "Q: What privileges does an attacker need?" >}}
  - The attacker requires hypervisor privileges on an AMD SEV-SNP platform.
{{< /details >}}

{{< details "Q: Is the attack scenario realistic?" >}}
  - Yes. The AMD SEV-SNP threat model explicitly considers the hypervisor as untrusted. BreakFAST operates entirely within that threat model.
{{< /details >}}

{{< details "Q: Does this affect non-confidential VMs?" >}}
  -  No. BreakFAST assumes a malicious hypervisor. In non-confidential VM deployments, the hypervisor is trusted.
{{< /details >}}

{{< details "Q: Does this apply to Intel TDX or Arm CCA?" >}}
  - The specific technique targets AMD Infinity Fabric. Whether analogous confused deputy vulnerabilities exist on other platforms remains an open question. Intel and Arm platforms have their own co-processors and sideband interconnects that have not been fully studied in this context.
{{< /details >}}

{{< details "Q: Is there a patch available?" >}}
  - AMD has acknowledged the findings and issued CVE-2025-61971 and CVE-2025-61972. Please refer to the AMD security advisory for patch availability.
{{< /details >}}

{{< details "Q: Why is BreakFAST an instance of the XCA attack class?" >}}
  - BreakFAST misconfigures the interconnect to break confidential computing security guarantees, thus making it an XCA attack.
{{< /details >}}

{{< details "Q: How is BreakFAST different from Fabricked?" >}}
  - BreakFAST is different to [Fabricked](/fabricked/) for multiple reasons. First, they target different components of the Infinity Fabric (I/O crossbar vs IOMS). Second, Fabricked uses the misconfigured interconnect to drop PSP writes, thus leaving the RMP uninitialized. In contrast, BreakFAST redirects PSP writes to FASTREG and FASTREGCNTL, ultimately allowing arbitrary reads and writes to the Control Fabric.
{{< /details >}}



## Authors
- [Philipp Giersfeld](https://giersfeld.com/)
- [Benedict Schlüter](https://benschlueter.com/)
- [Shweta Shinde](https://shwetashinde.com)

## Responsible Disclosure

We informed AMD about the vulnerability on September 26, 2025. After the discussion with AMD PSIRT, we agreed on an embargo date of May 12, 2026.

## CVE & AMD Response

AMD acknowledged the vulnerability to be in scope and issued an advisory under the following link [https://www.amd.com/en/resources/product-security/bulletin/amd-sb-3030.html](https://www.amd.com/en/resources/product-security/bulletin/amd-sb-3030.html).
BreakFAST was assigned CVE-2025-61971 and CVE-2025-61972.

## Citation

To cite our paper, please use the following BibTeX entry:

{{< citation >}}
@inproceedings{giersfeld2026breakfast,
  title={{BreakFAST: Confused Deputy Attack on Infinity Fabric to Break AMD SEV-SNP}},
  author={Philipp Giersfeld and Benedict Schl\"uter and Shweta Shinde},
  booktitle={47th IEEE Symposium on Security and Privacy (S\&P 26)},
  year={2026},
  month = may,
  address = {San Francisco, CA},
  publisher = {IEEE},
}
{{< /citation >}}
