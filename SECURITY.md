
SECURITY POLICY
PellAIri Research & Development
Policy owner: Katarina Pell
Research identity: PellAIri
Jurisdiction: Alberta, Canada
Version: 1.0
Effective date: November 2, 2026
Status: Initial policy
1. Purpose
This Security Policy establishes the security principles, vulnerability reporting procedures, authorization boundaries and incident-handling expectations governing projects developed, maintained or researched by Katarina Pell.
The policy applies to:
PellAIri websites, publications and research infrastructure.
Pre-Execution Decision Sandbox (PEDS).
AI evaluation and experimental research projects.
Five-Voice Experiment.
Fifth Signal.
Turn-Loss Audit.
GitHub repositories and associated software.
Technical investigations and research documentation.
Future software, systems and research projects.
Individual projects may maintain additional security requirements appropriate to their technical architecture and risk profile.
2. Security Principles
All covered projects should follow these principles:
Authorization before execution: Access, testing and modifications must remain within explicitly granted authority.
Least privilege: Access should be limited to the permissions necessary for an authorized task.
Human oversight: Security-sensitive decisions must remain subject to appropriate human authorization.
Evidence integrity: Security findings must preserve their provenance and distinguish observations from assumptions.
Separation of environments: Experimental, development and operational systems should be distinguished.
Controlled disclosure: Vulnerability information must be handled responsibly.
Reversibility: Changes should be reviewable and reversible where technically practical.
Accountability: Security actions should have an identifiable authorization basis and audit trail.
3. Supported Versions
Support status is maintained separately for each repository and software project.
A version is considered supported only when its maintainers explicitly identify it as receiving security maintenance.
Version status
Security support
Current supported release
Security updates where applicable
Previous supported release
As explicitly documented
Unsupported release
No guaranteed security updates
Experimental or prototype
No production-security guarantee
Archived project
No active maintenance guarantee
A project-specific SECURITY.md file or release documentation takes precedence when it provides more specific support information.
The existence of a repository, successful build, passing test or published research result does not independently establish that a system is secure.
4. Reporting a Vulnerability
Security vulnerabilities should be reported privately wherever possible.
Reports should include:
A description of the suspected vulnerability.
The affected project, repository or version.
Steps necessary to reproduce the issue, if known.
Expected versus observed behaviour.
Potential security implications.
Supporting logs, screenshots or other evidence, where safe to provide.
Any known limitations or uncertainty.
Reporters should avoid including passwords, private credentials, personal identification information or unrelated confidential material.
Reporting channels
Preferred channels:
GitHub Private Vulnerability Reporting, where enabled for the affected repository.
The official PellAIri contact channel for projects without an available private reporting mechanism.
Public issue trackers should not be used to disclose exploitable vulnerabilities before appropriate coordination.
Acknowledgment and response targets
The following are target response times, not guaranteed service levels:
Activity
Target
Initial acknowledgment
Within 5 business days
Initial assessment
Within 10 business days
Progress update
At least every 30 days while active
Resolution communication
When a remediation or disposition decision is reached
Urgent vulnerabilities involving active exploitation, unauthorized access or exposure of sensitive information should receive priority.
5. Vulnerability Assessment
Reported vulnerabilities will be assessed according to:
Reproducibility.
Technical severity.
Potential confidentiality impact.
Potential integrity impact.
Potential availability impact.
Scope of affected systems.
Required permissions or access.
Evidence quality.
Potential for exploitation.
Availability of mitigation or remediation.
Reports may be classified as:
CONFIRMED: Reproduced and technically substantiated.
PARTIAL: Some aspects are supported, but additional verification is required.
UNCONFIRMED: Plausible report without sufficient verification.
NOT REPRODUCIBLE: Available evidence does not establish the reported behaviour.
OUT OF SCOPE: The reported issue does not fall within the project's authorized security scope.
A report being unconfirmed does not necessarily mean the underlying concern is invalid.
6. Authorization and Scope Boundaries
No security policy grants blanket authorization to access, test, modify or interfere with third-party systems.
Testing must remain within the explicit permissions of the system owner.
The following activities require appropriate authorization:
Penetration testing.
Network scanning.
Exploit testing.
Access to restricted systems.
Collection of non-public information.
Modification of production environments.
Access to another person's account or device.
Testing involving third-party infrastructure.
Publicly accessible information does not automatically authorize intrusive testing.
Where authorization is unclear, testing must stop until permission is established.
7. Responsible Vulnerability Disclosure
Security researchers are expected to:
Act in good faith.
Avoid unnecessary access to information.
Avoid disrupting services.
Avoid modifying or deleting data.
Avoid accessing accounts or systems beyond the authorized scope.
Preserve sufficient evidence to explain the finding.
Report vulnerabilities privately where practical.
Allow a reasonable opportunity for assessment and remediation.
PellAIri will seek to acknowledge good-faith reports and coordinate remediation where appropriate.
No blanket legal immunity or protection from third-party action is promised by this policy.
8. Security Remediation
Confirmed vulnerabilities should be addressed according to severity and available resources.
Remediation may include:
Software patches.
Configuration changes.
Access-control corrections.
Credential rotation.
Removal of exposed information.
Infrastructure changes.
Additional validation.
Temporary mitigation or service suspension.
Security fixes should be documented with:
Vulnerability reference or identifier.
Affected component.
Description of the issue.
Remediation undertaken.
Verification method.
Known remaining limitations.
Original evidence and historical records should be preserved where appropriate.
9. Testing and Validation Standards
Security testing must distinguish between:
Developer verification: Tests conducted by the developer or project maintainer.
Independent validation: Testing conducted by a separate reviewer who did not implement the relevant control.
Adversarial validation: Testing designed to challenge assumptions, identify bypasses and discover failure conditions.
Passing developer tests does not establish independent security validation.
No project should claim complete security, zero vulnerabilities or guaranteed protection based solely on successful testing.
Untested conditions and known limitations should be disclosed where material.
10. Audit Records and Evidence Integrity
Security-sensitive actions should be documented where practical.
Records may include:
Authorization and permission references.
Dates and times.
Relevant project or repository identifiers.
Configuration and version information.
Test inputs and outputs.
Findings and remediation history.
Verification results.
Unresolved issues.
For PEDS and related decision systems, records should distinguish:
Original inputs.
Simulation outputs.
Independent analytical results.
Human authorization.
Execution status.
Revocation events.
Audit and integrity verification.
A simulation result is not authorization to execute an action.
11. Credentials and Sensitive Information
Credentials, API keys, access tokens and private configuration information must be protected.
They should not be committed to public repositories or included in public research publications.
Where exposure is suspected, appropriate containment measures should be taken, including credential revocation or rotation.
Access should be granted only to authorized individuals and services.
12. Security Incidents
Suspected security incidents should be documented, assessed and addressed.
The response process should include:
Identification of the incident.
Preservation of available evidence.
Assessment of affected systems and information.
Containment of ongoing exposure.
Investigation of the cause.
Remediation or mitigation.
Verification of corrective measures.
Documentation and appropriate notification.
Where personal information is involved, applicable privacy and breach-notification obligations must also be considered.
13. Third-Party Dependencies
Projects may rely on external platforms, infrastructure, software libraries and service providers.
Security assessments should consider:
Dependency vulnerabilities.
Provider security practices.
Access permissions.
Credential exposure.
Data processing arrangements.
External service availability.
Changes to third-party terms or functionality.
PellAIri cannot guarantee the security of infrastructure operated by independent providers.
14. Experimental and Prototype Systems
Experimental systems are not automatically production-ready.
Unless expressly documented otherwise:
Prototypes must not be represented as independently security-certified.
Simulation environments must remain distinct from live execution environments.
Test credentials and production credentials should be separated.
Experimental results must not be presented as proof of operational security.
Deployment requires an appropriate review and authorization decision.
For PEDS, the default operational position remains HOLD until the relevant validation and human authorization requirements have been satisfied.
15. Public Disclosure
A vulnerability may be disclosed publicly after appropriate assessment and coordination.
Public disclosure should consider:
Whether remediation is available.
Whether exploitation is ongoing.
Whether affected parties have been notified.
Whether disclosure creates additional security risks.
Whether the evidence supports the published claims.
Research publications should distinguish verified findings, reported findings, hypotheses and unresolved questions.
16. Policy Review and Changes
This policy will be reviewed when:
New projects or systems are introduced.
Significant security incidents occur.
Material changes are made to authorization boundaries.
New vulnerabilities reveal weaknesses in existing procedures.
Applicable legal or regulatory requirements change.
Changes should be documented through version history.
No policy revision should be interpreted as retroactive authorization for previously unauthorized activity.
17. Contact
Security Policy Owner: Katarina Pell
Research Identity: PellAIri
Jurisdiction: Alberta, Canada
Vulnerability reports should use the private reporting channel of the affected repository where available, or the official PellAIri contact channel.
Reports should identify the affected project and provide enough information for an initial assessment without unnecessarily exposing sensitive information.
Policy Statement
Security is not established by intention, successful execution or the absence of reported vulnerabilities.
It is established through defined authority, controlled access, evidence-based verification, responsible disclosure, documented remediation and continuing review.
Human authorization remains distinct from technical capability.