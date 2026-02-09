---
title: "Experiência"
description: "Minha jornada profissional em tecnologia"
date: 2024-01-01
draft: false
hidemeta: true
ShowToc: false
showBreadCrumbs: false
---

<style>
.timeline {
  position: relative;
  max-width: 800px;
  margin: 0 auto;
  padding: 20px 0;
}

.timeline::before {
  content: '';
  position: absolute;
  left: 20px;
  top: 0;
  bottom: 0;
  width: 3px;
  background: var(--primary);
  border-radius: 2px;
}

@media (min-width: 768px) {
  .timeline::before {
    left: 50%;
    transform: translateX(-50%);
  }
}

.timeline-item {
  position: relative;
  margin-bottom: 30px;
  padding-left: 50px;
}

@media (min-width: 768px) {
  .timeline-item {
    width: 50%;
    padding-left: 0;
    padding-right: 40px;
  }
  
  .timeline-item:nth-child(odd) {
    margin-left: 0;
    text-align: right;
  }
  
  .timeline-item:nth-child(even) {
    margin-left: 50%;
    padding-left: 40px;
    padding-right: 0;
    text-align: left;
  }
}

.timeline-dot {
  position: absolute;
  left: 12px;
  top: 5px;
  width: 18px;
  height: 18px;
  background: var(--primary);
  border-radius: 50%;
  border: 3px solid var(--theme);
}

@media (min-width: 768px) {
  .timeline-item:nth-child(odd) .timeline-dot {
    right: -9px;
    left: auto;
  }
  
  .timeline-item:nth-child(even) .timeline-dot {
    left: -9px;
  }
}

.timeline-date {
  font-size: 0.85rem;
  color: var(--secondary);
  font-weight: 600;
  margin-bottom: 5px;
}

.timeline-title {
  font-size: 1.1rem;
  font-weight: 700;
  margin-bottom: 3px;
  color: var(--primary);
}

.timeline-company {
  font-size: 1rem;
  font-weight: 500;
  margin-bottom: 8px;
}

.timeline-desc {
  font-size: 0.9rem;
  line-height: 1.5;
  color: var(--secondary);
}

.timeline-tech {
  margin-top: 8px;
  font-size: 0.8rem;
  color: var(--secondary);
}

.timeline-tech code {
  background: var(--code-bg);
  padding: 2px 6px;
  border-radius: 3px;
  margin-right: 4px;
}
</style>

<div class="timeline">

<div class="timeline-item">
<div class="timeline-dot"></div>
<div class="timeline-date">2022 — Presente</div>
<div class="timeline-title">Eng. de Dados/Software Sênior</div>
<div class="timeline-company">🏦 Itaú Unibanco</div>
<div class="timeline-desc">
Liderando desenvolvimento de sistema de gestão de trading. Reduzi tempo de gestão da mesa em 70%.
</div>
<div class="timeline-tech"><code>Python</code> <code>AWS</code> <code>SQL</code></div>
</div>

<div class="timeline-item">
<div class="timeline-dot"></div>
<div class="timeline-date">2021 — 2022</div>
<div class="timeline-title">Engenheira de Software</div>
<div class="timeline-company">💼 XP Inc.</div>
<div class="timeline-desc">
Microsserviços de alta disponibilidade para maior plataforma de investimentos do Brasil. Arquitetura orientada a eventos em escala.
</div>
<div class="timeline-tech"><code>.NET Core</code> <code>Redis</code> <code>Azure</code></div>
</div>

<div class="timeline-item">
<div class="timeline-dot"></div>
<div class="timeline-date">2020 — 2021</div>
<div class="timeline-title">Engenheira de Software</div>
<div class="timeline-company">🏦 Itaú Unibanco</div>
<div class="timeline-desc">
Microsserviços de análise de crédito. Garantia de compliance com regulamentações financeiras.
</div>
<div class="timeline-tech"><code>.NET Core</code> <code>MongoDB</code> <code>AWS Lambda</code></div>
</div>

<div class="timeline-item">
<div class="timeline-dot"></div>
<div class="timeline-date">2018 — 2020</div>
<div class="timeline-title">Eng. de Software Júnior</div>
<div class="timeline-company">🏦 Itaú Unibanco</div>
<div class="timeline-desc">
Modernização de sistemas legados. Reduzi tempo de cálculo em 60% através de caching e paralelismo.
</div>
<div class="timeline-tech"><code>C#</code> <code>.NET</code> <code>SQL Server</code></div>
</div>

<div class="timeline-item">
<div class="timeline-dot"></div>
<div class="timeline-date">2017 — 2018</div>
<div class="timeline-title">Estagiária de Desenvolvimento</div>
<div class="timeline-company">🏦 Itaú Unibanco</div>
<div class="timeline-desc">
Primeira experiência profissional. Práticas de desenvolvimento enterprise e domínio bancário.
</div>
<div class="timeline-tech"><code>C#</code> <code>SQL Server</code></div>
</div>

<div class="timeline-item">
<div class="timeline-dot"></div>
<div class="timeline-date">2017</div>
<div class="timeline-title">Estagiária de BI</div>
<div class="timeline-company">🚗 General Motors</div>
<div class="timeline-desc">
Dashboards de business intelligence e relatórios. Soluções de automação com Power BI e Excel.
</div>
<div class="timeline-tech"><code>Power BI</code> <code>Excel</code> <code>VBA</code></div>
</div>

</div>
