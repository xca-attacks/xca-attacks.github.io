---
title: "Mior"
description: "Breaking AMD SEV-SNP with Device-as-Memory"
summary: "Mior: Breaking AMD SEV-SNP with Device-as-Memory"
date: 2026-09-04T00:04:48+02:00
lastmod: 2026-09-04T00:04:48+02:00
draft: false
menu:
  docs:
    parent: ""
    identifier: "mior"
weight: 810
toc: true
seo:
  title: "Mior | XCA"
  description: "Mior: Breaking AMD SEV-SNP with Device-as-Memory"
  canonical: ""
  noindex: false
---
<link rel="stylesheet" href="/img-theme.css">
<div class='text-center' style='padding-bottom: 3rem;'>
<div>
   <img src="/Mior-symbol.svg" alt="Mior logo" class='' style='margin-top: 3rem; margin-bottom: 1rem; height: 250px; width: auto;'>
</div>
<h1 class='h1'>Mior</h1>
<p class="lead">Breaking AMD SEV-SNP with Device-as-Memory<br/> (<a href="https://www.sigsac.org/ccs/CCS2026/">ACM CCS '26</a>)</p>
<div class="row justify-content-center">
  <div class="col-lg-5 col-sm-6  text-center" style="margin-top: 1.2rem">
    <div class="d-flex flex-column flex-sm-row w-100 text-center">
      <a class="btn btn-primary btn-cta rounded-pill btn-lg head-button" href="/mior/mior_ccs26.pdf" role="button">Paper</a>
    </div>
  </div>
<div class="col-lg-5 col-sm-6  " style="margin-top: 1.2rem">
    <div class="d-flex flex-column flex-sm-row" >
      <a class="btn btn-primary btn-cta rounded-pill btn-lg head-button" href="https://github.com/xca-attacks/mior" role="button">Source</a>
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

Confidential computing allows cloud tenants to run sensitive workloads without
trusting the cloud service provider. Hardware-based trusted execution
environments, such as AMD SEV-SNP, protect these workloads inside Confidential
Virtual Machines (CVMs). With Mior, we present a software-only attack that
compromises SEV-SNP by redirecting memory accesses of the secure co-processor
(PSP) to an attacker-controlled device. The device acts as a substitute for
DRAM, allowing the PSP initialization checks to succeed while leaving critical
memory protections uninitialized. A malicious hypervisor can then read and
modify CVM memory or forge valid attestation reports for any guest.

### AMD SEV-SNP

Ordinary virtual machines rely on the hypervisor to isolate tenants. SEV-SNP
extends this isolation to protect a guest from the hypervisor itself, using
memory encryption and hardware-enforced access control. A central data
structure, the Reverse Map Table (RMP), tracks ownership and permissions for
physical memory pages. The encryption of guest memory provides confidentiality,
while the RMP protects its integrity. The PSP initializes this table and manages
security-sensitive guest metadata. This initializaiton is critical. An attacker
that can stop this initialization from happening can break all SEV-SNP
guarantees.

### AMD's Infinity Fabric

Modern AMD processors connect CPU cores, memory controllers, peripheral devices,
and the PSP through the Infinity Fabric. Its Data Fabric routes memory
transactions according to configurable address ranges. Some addresses lead to
DRAM; others lead to device memory exposed through memory-mapped I/O (MMIO),
such as a GPU memory. Different entry points into the fabric can have
different routing configurations. As a result, the same physical address can
lead to DRAM for one component and to a device for another. Mior exploits this
difference between the PSP view of memory and the routing applied to
its accesses.

{{< theme-image
    light="./typst-illustrations/fabric-overview-light.svg"
    dark="./typst-illustrations/fabric-overview-dark.svg"
    alt="Infinity Fabric connecting CPU cores, the PSP, memory controllers, and peripheral devices"
    description="Mior configures the PSP fabric entry point to route selected addresses to GPU memory, while CPU accesses still reach DRAM.">}}

### Mior Overview

Mior operates within the SEV-SNP threat model, where the hypervisor, motherboard
firmware (BIOS or UEFI), and peripheral devices are untrusted. We modify the
BIOS to leave the relevant Data Fabric configuration registers unlocked. The
malicious hypervisor then installs a routing rule at the PSP entry point that
redirects selected DRAM accesses to device memory. The hypervisor can carfeully
choose rules at other entry points to hide this redirection from the PSP
memory-map checks.

The PSP builds its memory map before initializing SEV-SNP. It uses this map to
reject addresses that lead to MMIO rather than DRAM. However, the PSP reads
routing registers through a broadcast operation that combines the values from
different fabric components using a bitwise OR. When these components have
different configurations, the combined result can conceal a malicious MMIO
range. The PSP therefore accepts addresses as DRAM even though its own accesses
to them will reach a device via MMIO.

{{< theme-image
    light="./typst-illustrations/broadcast-or-light.svg"
    dark="./typst-illustrations/broadcast-or-dark.svg"
    alt="Benign and malicious routing configurations produce the same broadcast OR result: 0xd3000 OR 0x01000 is 0xd3000, and 0xd3fff OR 0x01023 is 0xd3fff. The malicious range is missing from the PSP memory map."
    description="Broadcast reads combine routing registers using bitwise OR. A malicious range (RM) at the PSP entry point can be hidden by a benign range (RB) at another entry point. The PSP accepts RM as DRAM even though its accesses reach MMIO.">}}

What can an attacker do with this misrouting? The obvious approach is to drop
the PSP writes that initialize the RMP. When we attempted this, however, we
find that the PSP reads back the RMP entries after writing them. It would
therefor detect the missing values and fail during initialization. Instead, we
redirect these accesses to an attacker-controlled PCIe device, such as a
commodity GPU. The device memory behaves like DRAM: it stores the values the PSP
writes and returns them unchanged on later reads. We call this primitive
_Device-as-Memory_. The read-back check passes, yet the RMP in DRAM, which the
CPU uses to enforce isolation, never receives the PSP writes. We apply this to
the RMP entries that protect the RMP itself. These entries stay uninitialized,
so the hypervisor can modify the rest of the RMP and remove the protection of
guest metadata.

We demonstrate two consequences. First, we corrupt encrypted guest metadata to
enable debugging on a production CVM, allowing the hypervisor to use the PSP
debug commands to read and write guest memory. Second, we copy the encrypted
launch measurement that the PSP stores in a benign guest’s metadata into the
metadata of a malicious guest. The PSP then signs attestation reports containing
the benign measurement, even though the launched image is different. This
results in a forged attestation report which does not correctly represent the
state of the CVM.

### What went wrong?

The PSP security checks rely on a memory map that does not faithfully
represent the fabric routing configuration. A bitwise OR of register values
cannot describe all the address ranges configured independently across the
fabric. Mior exploits this mistake and uses device memory to satisfy the PSP
read-back checks. Those checks confirm that data was stored somewhere, but not
that it reached the DRAM used by the CPU to enforce isolation. A defense must
account for each component’s routing configuration or enforce a consistent
configuration across the fabric.

## Affected Hardware

We demonstrated the end-to-end attack on an AMD Zen 5 EPYC 9135 processor with
SEV-SNP firmware API version 1.58.4. We also confirmed with source-code analysis
that Zen 3 and Zen 4 use the same Data Fabric routing configuration logic.
However, we did not evaluate the attack experimentally on those generations. We
therefore show that Zen 5 is affected by Mior and consider Zen 3 and Zen 4
potentially affected.

## FAQ

{{< details "Q: What are the requirements for the attack?" >}}

- The attacker controls the BIOS and hypervisor and can use a PCIe device, such
  as a GPU, to back redirected memory accesses. These components are outside the
  SEV-SNP trusted computing base.

{{< /details >}}

{{< details "Q: Why is Mior an XCA attack?" >}}

- Mior corrupts interconnect routing to violate a trusted execution
  environment security guarantees. It is an instance of the Interconnect
  Corruption Attacks (XCA) class.

{{< /details >}}

{{< details "Q: How is Mior different from Fabricked?" >}}

- [Fabricked](/fabricked/) drops PSP writes intended to initialize the RMP. Mior
  hides malicious MMIO routing from the PSP memory map and backs redirected
  reads and writes with device memory. This lets Mior pass read-back checks that
  would detect dropped writes.

{{< /details >}}

{{< details "Q: Why the name MIOR?" >}}

- MIOR is a blend word of MMIO and OR, signifying that we use MMIO rerouting and
  hiding it with the mistaken OR reduction the PSP performs.

{{< /details >}}

{{< details "Q: Is the attack scenario realistic?" >}}

- We operate in the threat model defined for AMD SEV-SNP. AMD explicitly
  distrusts the hypervisor, and confidential computing specifically aims to
  protect sensitive data from a potentially malicious cloud provider.

{{< /details >}}

{{< details "Q: Does Mior affect ordinary virtual machines?" >}}

- Mior targets the protection of confidential VMs against their host. Ordinary
  VMs already trust the hypervisor and platform firmware, so a malicious host
  can access them without this attack.

{{< /details >}}

{{< details "Q: Does this affect Intel TDX or Arm CCA?" >}}

- We did not evaluate Mior on Intel TDX or Arm CCA. The broader problem of
  validating memory routing is relevant to other confidential computing
  architectures, but this paper demonstrates an attack on AMD SEV-SNP.

{{< /details >}}

{{< details "Q: Does this apply to SEV or SEV-ES?" >}}

- We did not evaluate those versions. Unlike SEV-SNP, SEV and SEV-ES do not
  provide the guest-memory integrity guarantees targeted by Mior.

{{< /details >}}

{{< details "Q: What was AMD’s response?" >}}

- AMD acknowledged the vulnerability and agreed to coordinated disclosure. MIOR
  has been assigned CVE-2026-0462, and an updated firmware version has been
  published which mitigates the vulnerability.

{{< /details >}}

## Authors

- [Chris Wech](https://chriswe.ch)
- [Philipp Giersfeld](https://giersfeld.com/)
- [Benedict Schlüter](https://benschlueter.com/)
- [Shweta Shinde](https://shwetashinde.com)

## Responsible Disclosure

We reported Mior to AMD on February 12, 2026. AMD acknowledged the
vulnerability, and we agreed on an embargo ending November 10, 2026.

## CVE & AMD Response

MIOR has been assigned CVE-2026-0462.

## Citation

To cite our paper, please use the following BibTeX entry:

{{< citation >}}
@inproceedings{wech2026mior,
  title = {{Mior: Breaking AMD SEV-SNP with Device-as-Memory}},
  author = {Chris Wech and Philipp Giersfeld and Benedict Schlüter and Shweta Shinde},
  booktitle = {Proceedings of the 2026 ACM SIGSAC Conference on Computer and Communications Security},
  year = {2026},
  month = nov,
  address = {The Hague, Netherlands},
  publisher = {Association for Computing Machinery},
  doi = {10.1145/3830454.3846723},
}
{{< /citation >}}
