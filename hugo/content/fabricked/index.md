---
title: "Fabricked"
description: "Misconfiguring Infinity Fabric to Break AMD SEV-SNP"
summary: "Fabricked: Misconfiguring Infinity Fabric to Break AMD SEV-SNP"
date: 2024-04-04T00:04:48+02:00
lastmod: 2024-04-04T00:04:48+02:00
draft: false
menu:
  docs:
    parent: ""
    identifier: "fabricked"
weight: 810
toc: true
seo:
  title: "Fabricked | XCA" # custom title (optional)
  description: "Misconfiguring Infinity Fabric to Break AMD SEV-SNP" # custom description (recommended)
  canonical: "" # custom canonical URL (optional)
  noindex: false # false (default) or true
---
<link rel="stylesheet" href="/img-theme.css">
<div class='text-center' style='padding-bottom: 3rem;'>
<div>
   <img src="/Fabricked-symbol.svg" class='' style='margin-top: 2rem; margin-bottom: -1rem; width: 300px;'>
</div>
<h1 class='h1'>Fabricked</h1>
<p class="lead">Misconfiguring Infinity Fabric to Break AMD SEV-SNP<br/> (<a href='https://www.usenix.org/conference/usenixsecurity26'>USENIX Security 2026</a>)</p>
<div class="row justify-content-center">
  <div class="col-lg-5 col-sm-6  text-center" style="margin-top: 1.2rem">
    <div class="d-flex flex-column flex-sm-row w-100 text-center">
      <a class="btn btn-primary btn-cta rounded-pill btn-lg head-button" href="/fabricked/fabricked_usenix26.pdf" role="button">Paper</a>
    </div>
  </div>
<div class="col-lg-5 col-sm-6  " style="margin-top: 1.2rem">
    <div class="d-flex flex-column flex-sm-row" >
      <a class="btn btn-primary btn-cta rounded-pill btn-lg head-button" href="https://github.com/fabricked-attack/" role="button">Source</a>
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

Confidential computing allows cloud tenants to offload sensitive computations and data to remote resources without needing to trust the cloud service provider. Hardware-based trusted execution environments, like AMD SEV-SNP, achieve this by creating Confidential Virtual Machines (CVMs). With Fabricked, we present a novel software-based attack that manipulates memory routing to compromise AMD SEV-SNP. By redirecting memory transactions, a malicious hypervisor can deceive the secure co-processor (PSP) into improperly initializing SEV-SNP. This enables the attacker to perform arbitrary read and write accesses within the CVM address space, thus breaking SEV-SNP core security guarantees.

### What is AMD SEV-SNP?

Standard cloud environments expose tenant computation and data in use to potentially untrusted cloud service providers. Confidential computing addresses this by using Confidential Virtual Machines (CVMs): hardware-shielded environments that isolate active workloads and guarantee complete data privacy from the host. Secure Encrypted Virtualization-Secure Nested Paging (SEV-SNP) is an AMD hardware extension that enables CVMs on AMD server CPUs.

### What is the Infinity Fabric?

Modern AMD System-on-Chips (SoCs) use a chiplet-based architecture. The core idea is to manufacture individual CPU blocks on separate dies and link them together via a high-speed interconnect. While this design significantly improves manufacturing yields, it also introduces complexity in inter-component communication. AMD addresses this with the Infinity Fabric, which is responsible for coherent data transport, memory routing, and address mapping across CPU cores, memory controllers, and peripheral devices. Because platform configurations vary between different systems and boot sequences, the Infinity Fabric must be dynamically configured during every CPU boot sequence. AMD delegates parts of this configuration process to the motherboard firmware, also known as BIOS or UEFI.

{{< theme-image
    light="./typst-illustrations/fabric-overview-light.svg"
    dark="./typst-illustrations/fabric-overview-dark.svg"
    alt="High level overview of the Infinity Fabric"
    description="Schematic overview of the Infinity Fabric.">}}


### Fabricked Overview

In the confidential computing threat model, the UEFI is untrusted and cloud-provider-controlled. In Fabricked, we first identify that the untrusted UEFI is in charge of locking down parts of the Infinity Fabric configuration. As an attacker, we modify the UEFI to skip these API calls. This leaves the Infinity Fabric configurable by the attacker even after SEV-SNP is activated on the machine.

The attacker, i.e., a malicious hypervisor, can therefore modify the Infinity Fabric to re-route DRAM memory transactions. Since the Infinity Fabric connects not only the CPU cores but also the secure co-processor (PSP) to the DRAM, we can manipulate PSP read/write operations to DRAM. We use this attacker capability to compromise SEV-SNP initialization. Specifically, we identify that during the SEV-SNP initialization, the PSP sets up a critical data structure, the RMP, that enforces memory access control rules to CVM memory. During this setup, the PSP has to perform memory writes to the DRAM. By misconfiguring the Infinity Fabric before these PSP writes, we are able to drop them. This results in an uninitialized RMP, i.e., it remains completely unchanged, retaining its insecure default entries set up by the malicious hypervisor. In other words, by using Fabricked, the attacker bypasses parts of the SEV-SNP initialization while tricking it into believing it succeeded. When the victim launches CVMs subsequently on the platform, the hypervisor can access their memory as the RMP enforcement is useless for all practical purposes.

{{< theme-image
    width="60%"
    light="./typst-illustrations/attack-overview-light.svg"
    dark="./typst-illustrations/attack-overview-dark.svg"
    alt="High level overview of the Fabricked Attack"
    description="High-level overview of the Fabricked attack: during SNP_INIT the attacker maliciously misroutes the security co-processor writes to DRAM. This results in an RMP with insecure default entries.">}}


### What went wrong?

Fabricked is possible due to two critical flaws. First, the hypervisor can maliciously corrupt some Infinity Fabric routing rules. Second, when the security co-processor subsequently issues memory requests, the corrupted routing rules take precedence over the correct ones — silently misdirecting writes that should have initialized the RMP.

### Attack Complexity

Fabricked operates as a fully deterministic, software-only exploit with a 100% success probability. It does not depend on any code running inside the victim CVM and requires no physical access to the hardware.

## Affected Hardware

We confirmed the vulnerability on AMD Zen 5 EPYC processors running SEV-SNP.
However, the AMD advisory also lists firmware updates for Zen 3 and Zen 4
processors. We note that the patchnotes for these systems also list
CVE-2025-54510 mitigations. Therefore, we assume Fabricked affects Zen 3, Zen 4, and
Zen 5.

## FAQ
{{< details "Q: Does this attack have implications beyond SEV-SNP?" >}}

- Fabricked misroutes memory accesses of the AMD on-chip security co-processor, the PSP. We have not studied the impact of the vulnerability beyond SEV-SNP.

{{< /details >}}


{{< details "Q: Does Fabricked affect non-confidential VMs that I have in the cloud?" >}}

- No. Fabricked assumes a malicious hypervisor and UEFI to reconfigure the Infinity Fabric. In the non-confidential VM threat model, the hypervisor and the UEFI are considered trusted.

{{< /details >}}


{{< details "Q: What are the requirements for the attack?" >}}

- An attacker needs UEFI and hypervisor privileges to successfully mount the Fabricked Attack.

{{< /details >}}


{{< details "Q: Is the attack scenario realistic?" >}}

- We operate in AMD's threat model defined for SEV-SNP. AMD explicitly distrusts the UEFI, thus an attacker can modify the UEFI. Further, since confidential computing aims to protect sensitive data from a cloud provider it can be assumed that the cloud providers have custom UEFI implementations.

{{< /details >}}


<!-- {{< details "Q: How is this an XCA attack?" >}}
- Fabricked manipulates the interconnect to maliciously re-route co-processor memory accesses.
{{< /details >}} -->


{{< details "Q: Why the name Fabricked? " >}}

- Our attack misconfigures the Infinity Fabric to ‘brick’ SEV-SNP. Therefore, we call the attack Fabricked.

{{< /details >}}


{{< details "Q: What was the response from AMD?" >}}

- AMD acknowledged the attack and released fixes. You can find more information on their advisory page: [https://www.amd.com/en/resources/product-security/bulletin/amd-sb-3034.html](https://www.amd.com/en/resources/product-security/bulletin/amd-sb-3034.html).

{{< /details >}}


{{< details "Q: Does this have implications on Arm CCA or Intel TDX?" >}}

- The attack at hand does not work on Intel TDX or Arm CCA. However, we note
that a similar vulnerability has been found internally on Intel systems
[INTEL-SA-00960](https://www.intel.com/content/www/us/en/developer/articles/technical/software-security-guidance/advisory-guidance/trusted-execution-configuration-register-access.html).

{{< /details >}}


{{< details "Q: Does this attack apply to other versions of SEV (e.g., SEV-ES)?" >}}

- No. AMD SEV and SEV-ES do not guarantee any guest integrity and are thereby widely considered insecure-by-design. For this reason, we did not evaluate our attack against SEV and SEV-ES.

{{< /details >}}

{{< details "Q: Can I use the Fabricked logo?" >}}

- Sure, the logo is free to use.

{{< /details >}}

{{< details "Q: Why is Fabricked an instance of the XCA attack class?" >}}
  - Fabricked misconfigures the interconnect to break confidential computing security guarantees, thus making it an XCA attack.
{{< /details >}}

{{< details "Q: How is Fabricked different from BreakFAST?" >}}
  - Fabricked is different from [BreakFAST](/breakfast/) in what component it reconfigures in
    the Infinity Fabric and what the results of that reconfiguration are.
    Fabricked targets the IOMS while BreakFAST targets the I/O crossbar.
    In Fabricked, we drop writes by the PSP which should reach DRAM, while
    BreakFAST redirects the PSP read/writes into the Control Fabric. BreakFAST
    therefore allows an attacker to control parts of the Control Fabric, while
    Fabricked disables integrity protection for SEV-SNP.
{{< /details >}}



## Authors

- [Chris Wech](https://chriswe.ch)
- [Benedict Schlüter](https://benschlueter.com/)
- [Shweta Shinde](https://shwetashinde.com)

## Responsible Disclosure

We informed AMD about the vulnerability on August 3, 2025. After the discussion with AMD PSIRT, we agreed on an embargo date of April 14, 2026.

## CVE & AMD Response

AMD acknowledged the vulnerability to be in scope and issued an advisory under the following link [https://www.amd.com/en/resources/product-security/bulletin/amd-sb-3034.html](https://www.amd.com/en/resources/product-security/bulletin/amd-sb-3034.html). Fabricked was assigned CVE-2025-54510.


## Citation

To cite our paper, please use the following BibTeX entry:

{{< citation >}}
@inproceedings{schlueter2026fabricked,
  title={{Fabricked: Misconfiguring Infinity Fabric to Break AMD SEV-SNP}},
  author={Benedict Schlüter and Christoph Wech and Shweta Shinde},
  booktitle={35th USENIX Security Symposium (USENIX Security 26)},
  year={2026},
  month = aug,
  address = {Baltimore, MD},
  publisher = {USENIX Association},
}
{{< /citation >}}
