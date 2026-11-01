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
<p class="lead">Breaking AMD SEV-SNP with Device-as-Memory<br/> (<a href="https://doi.org/10.1145/3830454.3846723">ACM CCS '26</a>)</p>
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

Confidential computing allows cloud tenants to run sensitive workloads without trusting the cloud service provider. Hardware-based trusted execution environments, such as AMD SEV-SNP, protect these workloads inside Confidential Virtual Machines (CVMs). With Mior, we present a software-only attack that compromises SEV-SNP by redirecting memory accesses of the secure co-processor (PSP) to an attacker-controlled device. The device acts as a substitute for DRAM, allowing the PSP’s initialization checks to succeed while leaving critical memory protections uninitialized. A malicious hypervisor can then read and modify CVM memory and obtain signed attestation reports that misrepresent the running guest.

### AMD SEV-SNP

Ordinary virtual machines rely on the hypervisor to isolate tenants. SEV-SNP extends this isolation to protect a guest from the hypervisor itself, using memory encryption and hardware-enforced access control. A central data structure, the Reverse Map Table (RMP), tracks ownership and permissions for physical memory pages. The PSP initializes this table and manages security-sensitive guest metadata. Protecting these structures is essential: encryption alone cannot prevent an attacker from corrupting or replaying their contents.

### AMD's Infinity Fabric

Modern AMD processors connect CPU cores, memory controllers, peripheral devices, and the PSP through the Infinity Fabric. Its Data Fabric routes memory transactions according to configurable address ranges. Some addresses lead to DRAM; others lead to device memory exposed through memory-mapped I/O (MMIO), such as a GPU’s memory. Different entry points into the fabric can have different routing configurations. As a result, the same physical address can lead to DRAM for one component and to a device for another. Mior exploits this difference between the PSP’s view of memory and the routing actually applied to its accesses.

{{< theme-image
    light="/fabricked/typst-illustrations/fabric-overview-light.svg"
    dark="/fabricked/typst-illustrations/fabric-overview-dark.svg"
    alt="Infinity Fabric connecting CPU cores, the PSP, memory controllers, and peripheral devices"
    description="Schematic overview of the Infinity Fabric, shared with Fabricked.">}}

### Mior Overview

Mior operates within the SEV-SNP threat model, where the hypervisor, motherboard firmware (BIOS or UEFI), and peripheral devices are untrusted. We modify the BIOS to leave the relevant Data Fabric configuration registers unlocked. The malicious hypervisor then installs a routing rule at the PSP’s entry point that redirects selected DRAM accesses to device memory. Carefully chosen rules at other entry points hide this redirection from the PSP’s memory-map checks.

The PSP builds its memory map before initializing SEV-SNP. It uses this map to reject addresses that lead to MMIO rather than DRAM. However, the PSP reads routing registers through a broadcast operation that combines the values from different fabric components using a bitwise OR. When these components have different configurations, the combined result can conceal a malicious MMIO range. The PSP therefore accepts addresses as DRAM even though its own accesses to them will reach a device.

Simply dropping the PSP’s writes is insufficient: the PSP reads back the RMP entries to verify initialization. Our _Device-as-Memory_ primitive instead backs these accesses with an attacker-controlled PCIe device, such as a commodity GPU. The device stores the values written by the PSP and returns them on subsequent reads. The check succeeds, but the real RMP in DRAM has not received the corresponding writes. By targeting the entry that protects the RMP itself, we let the hypervisor modify other RMP entries and remove protection from guest metadata.

We demonstrate two consequences. First, we corrupt encrypted guest metadata to enable debugging on a production CVM, allowing the hypervisor to use the PSP’s debug commands to read and write guest memory. Second, we replay an encrypted launch measurement from a benign guest into the metadata of a malicious guest. The PSP then signs attestation reports containing the benign measurement, even though the launched image is different.

### What went wrong?

The PSP’s security checks rely on a memory map that does not faithfully represent the fabric’s routing configuration. A bitwise OR of register values cannot describe all the address ranges configured independently across the fabric. Mior exploits this mismatch and uses device memory to satisfy the PSP’s read-back checks. Those checks confirm that data was stored somewhere, but not that it reached the DRAM used by the CPU to enforce isolation. A defense must account for each component’s routing configuration or enforce a consistent configuration across the fabric.

### Attack Complexity

Mior requires control of the BIOS and hypervisor, plus a device that can back the redirected accesses. It needs no code inside the victim CVM and no physical tampering with the processor. In our evaluation, the debug attack succeeded in all 1,000 trials both with and without ciphertext hiding. After compromising the RMP, enabling debug access took about 1.7 milliseconds on average. This step uses repeated ciphertext corruption and took roughly two attempts on average. Forging a launch measurement additionally requires a preparation phase that launches a benign guest and saves its encrypted measurement.

## Affected Hardware

We demonstrated the end-to-end attack on an AMD Zen 5 EPYC 9135 processor with SEV-SNP firmware API version 1.58.4. We also confirmed that Zen 3 and Zen 4 use the same Data Fabric routing configuration logic. However, we did not have suitable BIOS-modification setups to run the full attack on those generations. The paper therefore considers them potentially affected; our end-to-end experimental confirmation is limited to Zen 5.

## FAQ

{{< details "Q: What are the requirements for the attack?" >}}

- The attacker controls the BIOS and hypervisor and can use a PCIe device, such as a GPU, to back redirected memory accesses. These components are outside the SEV-SNP trusted computing base.

{{< /details >}}

{{< details "Q: Is this attack scenario realistic?" >}}

- SEV-SNP is designed to protect tenants from an untrusted cloud provider. A provider can control the hypervisor, platform firmware, and attached devices. Mior uses these capabilities to attack the hardware isolation that should protect tenants from that provider.

{{< /details >}}

{{< details "Q: How is Mior different from Fabricked?" >}}

- [Fabricked](/fabricked/) drops PSP writes intended to initialize the RMP. Mior hides malicious MMIO routing from the PSP’s memory map and backs redirected reads and writes with device memory. This lets Mior pass read-back checks that would detect dropped writes.

{{< /details >}}

{{< details "Q: Does ciphertext hiding stop Mior?" >}}

- No. Both case studies succeeded with ciphertext hiding enabled. They target the guest context page, which the PSP encrypts directly and accesses differently from ordinary guest memory. Ciphertext hiding does not prevent the metadata corruption and replay used here.

{{< /details >}}

{{< details "Q: Does Mior break the attestation signature?" >}}

- Mior does not recover a signing key. It replaces the stored launch measurement with a previously saved benign measurement. The PSP then produces a valid signature over misleading evidence.

{{< /details >}}

{{< details "Q: Does Mior affect ordinary virtual machines?" >}}

- Mior targets the protection of confidential VMs against their host. Ordinary VMs already trust the hypervisor and platform firmware, so a malicious host can access them without this attack.

{{< /details >}}

{{< details "Q: Does this affect Intel TDX or Arm CCA?" >}}

- We did not evaluate Mior on Intel TDX or Arm CCA. The broader problem of validating memory routing is relevant to other confidential computing architectures, but this paper establishes an exploit for AMD SEV-SNP.

{{< /details >}}

{{< details "Q: Does this apply to SEV or SEV-ES?" >}}

- We did not evaluate those versions. Unlike SEV-SNP, SEV and SEV-ES do not provide the guest-memory integrity guarantees targeted by Mior.

{{< /details >}}

{{< details "Q: Why is Mior an XCA attack?" >}}

- Mior corrupts interconnect routing to violate a trusted execution environment’s security guarantees. It is an instance of the Interconnect Corruption Attacks (XCA) class.

{{< /details >}}

{{< details "Q: What was AMD’s response?" >}}

- AMD acknowledged the vulnerability and agreed to coordinated disclosure. TODO

{{< /details >}}

## Authors

- [Chris Wech](https://chriswe.ch)
- [Philipp Giersfeld](https://giersfeld.com/)
- [Benedict Schlüter](https://benschlueter.com/)
- [Shweta Shinde](https://shwetashinde.com)

## Responsible Disclosure

We reported Mior to AMD on February 12, 2026. AMD acknowledged the vulnerability, and we agreed on an embargo ending November 10, 2026.

## CVE & AMD Response

TODO

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
