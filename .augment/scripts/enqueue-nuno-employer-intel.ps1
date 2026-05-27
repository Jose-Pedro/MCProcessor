# enqueue-nuno-employer-intel.ps1
# Enqueue one airouter call (via clone-agent worker) to produce a strict
# JSON list of target employers in Aveiro+Coimbra districts across Nuno's
# three target profiles (hotel management, industrial QC, B2B export sales).
# Output lands in .augment/clone-agent/results/<id>.json; downstream
# nuno-build-roles-xlsx.ps1 parses the JSON and writes the Excel.

$ErrorActionPreference = 'Stop'
$scriptDir = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Path }

$system = @'
You are a Portuguese labour-market analyst with deep knowledge of employers
in the Aveiro and Coimbra districts. You output STRICT JSON only — no prose,
no markdown fences, no commentary. The JSON must parse with ConvertFrom-Json
on the first attempt.
'@

$prompt = @'
Produce a JSON object listing target employers and job-search entry points
for a Portuguese candidate (Nuno Miguel Alves Lopes) based in Aveiro who is
applying across three profiles in the Aveiro and Coimbra districts:

  PROFILES
  - hotel       : hotel / hostel / guesthouse operations and management
                  (front-of-house, F&B, revenue, GM track)
  - qc          : industrial quality control / quality assurance
                  (ceramics, automotive, food, packaging, electronics)
  - sales       : B2B export sales, account management, key accounts,
                  international business development

  CANDIDATE STRENGTHS (use to score fit 1-5)
  - 2.2x revenue growth at Castel Creative Living (hostel, 44 beds)
  - 60+ events orchestrated, Booking 8.9 score
  - Quality Control Lead at Domino Cerâmicas, exports PT/AF/EU
  - 3 years operational ground experience in France (fluent FR)
  - PT native, EN fluent, FR fluent, ES B1

Return JSON with EXACTLY this shape:

{
  "employers": [
    {
      "name": "string",
      "profile": "hotel|qc|sales",
      "sector": "string (one-liner)",
      "city": "string",
      "district": "Aveiro|Coimbra",
      "careers_url": "string (real URL if known, else empty string)",
      "fit_score": 1-5,
      "why_fit_pt": "string (one short sentence in European Portuguese)"
    }
  ],
  "job_board_searches": [
    {
      "board": "string",
      "profile": "hotel|qc|sales",
      "region": "Aveiro|Coimbra|both",
      "url": "string (live search URL pre-filled with keywords + region)"
    }
  ]
}

REQUIREMENTS
- employers: minimum 30 entries total, distributed roughly evenly across the
  three profiles. Real Portuguese companies with operations in Aveiro or
  Coimbra districts. Examples to consider (do not limit to these): for
  hotel — Montebelo, Vila Galé Coimbra, Hotel Aveiro Palace, Hotel
  Moliceiro, Quinta das Lágrimas, Curia Palace, Hotel Buçaco Palace;
  for qc — Revigrés, Aleluia Cerâmicas, Recer, Renault Cacia, Bosch
  Aveiro, Continental Mabor (Lousado is north but close), Simoldes,
  Vista Alegre, Nestlé Avanca; for sales — Vista Alegre, Renova,
  Bosch, Critical Software (Coimbra), Toyota Caetano Ovar.
- job_board_searches: 12 entries covering net-empregos.com, sapo
  emprego, hosco.com, indeed.pt, linkedin.com/jobs, alfajobs (or
  similar PT board) — each with realistic pre-filled URL using
  appropriate keywords for the profile and a region filter where the
  board supports it.
- All text fields use European Portuguese (no Brazilian variants) for
  the why_fit_pt field.
- DO NOT include any text outside the JSON object.
- DO NOT wrap the JSON in markdown code fences.
'@

& (Join-Path $scriptDir 'clone-agent-enqueue.ps1') `
    -Prompt $prompt `
    -System $system `
    -Kind 'freeform' `
    -Tag 'nuno-employer-intel' `
    -MaxTokens 8192

Write-Host "`nenqueued. next worker cycle picks it up; results -> .augment\clone-agent\results\<id>.json"
