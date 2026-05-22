# Academic Writing Rules

## General
- Use formal academic tone; third person preferred
- Be precise but accessible; avoid unnecessary jargon
- Every claim must be supported by citation, derivation, or evidence
- Do not plagiarize; cite all prior work that informs or relates to the contribution
- When describing code implementations, match the description to the actual code behavior

## LaTeX Conventions
- Number all significant equations with `\label{eq:name}`
- Use `\cref` for all cross-references (figures, equations, sections, tables)
- Use `\cite{}` for all references; prefer `\cite{Author2024}` format for bib keys
- Bold vectors with `\boldsymbol{}` or custom commands (`\bv`, `\br`, etc.)
- Use `\vec{}` only for arrow-notation vectors if needed

## Citation Practice
- Always cite foundational/seminal work (Helmholtz, Saffman, Crow, etc.)
- Cite the most recent and relevant work in the introduction
- When implementing someone else's method, cite the original paper
- When comparing against a method, cite it and describe it accurately
- Include DOIs in bibliography entries when available

## Paper-Specific
- **ACI paper:** Archival journal format; detailed mathematical derivations
- **OpenVortex paper:** SoftwareX format; focus on architecture, usage, and impact
- Both papers share the same bibliography; keep references consistent
