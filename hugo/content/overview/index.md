---
title: "Overview of XCA"
description: ""
summary: ""
date: 2026-04-12T00:04:48+02:00
lastmod: 2026-04-12T00:04:48+02:00
draft: false
weight: 5
toc: true
contributors: []
pinned: false
homepage: false
# slug: xca-overview
seo:
#  title: "" # custom title (optional)
#  description: "" # custom description (recommended)
#  canonical: "" # custom canonical URL (optional)
  noindex: false # false (default) or true
---
<link rel="stylesheet" href="/img-theme.css">

<div class='text-center' style='padding-bottom: 3rem;'>

<h1 class='h1'>Overview of Interconnect Corruption Attacks (XCA)</h1>
</div>

<center><em>
We discovered a new class of vulnerabilities in confidential computing that exploits the gap between performance-oriented interconnect design and security requirements. This post explains how we break AMD SEV-SNP isolation by manipulating the Infinity Fabric.
</em></center>

## The Chiplet Era: Interconnects as the new Backbone
Modern processors are no longer monolithic. As chip designs have scaled beyond what can be economically fabricated on a single die, CPU manufacturers have moved to chiplet-based architectures where different parts of an System-on-Chip (SoC) are separately manufactured and later connected over high-speed interconnects.

The Infinity Fabric is a proprietary interconnect from AMD that makes this possible for AMD-based platforms. It consists of two planes serving distinct roles. The Data Fabric handles coherent data movement at high bandwidth, which entails routing memory reads and writes between cores, memory controllers, and I/O subsystems, similar to the data plane in networking. To configure the data plane, Infinity Fabric introduces an internal control bus for the platform.
Known as the Control Fabric or System Management Network (SMN), it
maps configuration registers of all the components on the SoC (e.g., memory controllers,  IOMMUs, power management units, security processor).
Modifications to the Control Fabric has direct consequences for component behavior within the Data Fabric and may result in changes to platform routing.

{{< theme-image
    width="90%"
    light="./typst-illustrations/infinity-fabric-light.svg"
    dark="./typst-illustrations/infinity-fabric-dark.svg"
    alt="Infinity Fabric with the Data Fabric and Control Fabric planes."
    description="The Control Fabric acts as a configuration space for all components on the platform. The Data Fabric handles the data movement between those components.">}}

Together, these two planes ensure reliable and fast interaction between system components. Thus, corruption of these planes can not only undermine functionality but also break platform security.

## Confidential Computing

Confidential computing enables cloud tenants to offload sensitive computation to
remote cloud infrastructure without trusting the cloud service provider.
Hardware vendors provide trusted execution environments (TEEs) that enforce
isolation between the cloud operator and the user workloads. AMD SEV-SNP is a
production offering for this model, allowing users to run Confidential Virtual
Machines (CVMs) in the cloud, ensuring user code and data remain private and
tamper-proof, even against a fully malicious hypervisor. At the heart of AMD
SEV-SNP is a dedicated hardware root of trust called the Platform Security
Processor (PSP). The PSP underpins all SEV-SNP security guarantees.

<!-- ## What happens when the two worlds meet -->
## When Trusted Interconnects Meet Untrusted Software

AMD designed the Infinity Fabric for performance and flexibility. In traditional deployments, the BIOS and hypervisor are trusted system software; they configure the interconnect during boot, and the rest of the platform simply relies on that configuration being correct. Confidential computing changes this assumption. In the AMD SEV-SNP threat model, both the BIOS/UEFI and the hypervisor are under the control of the cloud service provider. Thus, they are explicitly untrusted. Yet both retain the ability to reconfigure interconnect behavior.
This creates a fundamental problem. The PSP enforces SEV-SNP security by writing to and reading from memory, initializing the security-critical data structures, and managing the CVM lifecycle. It does so assuming the interconnect will faithfully deliver those transactions to their intended destinations. But if an adversary can silently redirect, suppress, or intercept those transactions at the interconnect level, the PSP security reasoning breaks down: it believes it has initialized the platform correctly when, in reality, its writes either never arrived or arrived somewhere else entirely.

This is the gap that leads to a new family of vulnerabilities where the
untrusted software can misconfigure the interconnect to corrupt the data and
control plane with the goal of breaking confidential computing. We call these
Interconnect Corruption Attacks (XCA). So far, we have identified two ways that
an adversary can abuse its ability to reconfigure different parts of the
interconnect, as shown in Illustration 2.

{{< theme-video
    width="80%"
    light="./fabric-routing-light.mp4"
    dark="./fabric-routing-dark.mp4"
    alt="Infinity Fabric annotated with Fabricked and BreakFAST attacks."
    description="High-level overview of Infinity Fabric components corrupted by Fabricked and BreakFAST.">}}


List of XCA instances:
* [Fabricked](/fabricked/): reconfigure Data Fabric routing to tamper with RMP initialization
* [BreakFAST](/breakfast/): redirect PSP writes to on-chip components to hijack the Control Fabric

## The Broader Challenge

The Infinity Fabric configuration spans across dozens of SoC components, each with subtle interdependencies—a complex web of routing logic, address translation, and component interactions that cannot be exhaustively tested or formally verified at scale. A single misconfigured route can invisibly undermine security guarantees the PSP believes it has established, as demonstrated by instances of XCA. Securing confidential computing requires rethinking interconnect architectures from the ground up. We believe this challenge presents an important opportunity for the research community: as SoCs grow more complex and confidential computing becomes ubiquitous, interconnect security will be one of the critical aspects that determine whether these systems can deliver on their promises.
