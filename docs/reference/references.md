# References

External sources for human readers. AI agents should skip this file.

---

## Secure Coding

- [OWASP Cheatsheet Series](https://cheatsheetseries.owasp.org/)
- [CWE Top 25 Most Dangerous Software Weaknesses](https://cwe.mitre.org/top25/)
- [OWASP Top 10](https://owasp.org/www-project-top-ten/)

## API Design

- [RFC 7231 - HTTP/1.1 Semantics and Content](https://tools.ietf.org/html/rfc7231)
- [RFC 9110 - HTTP Semantics](https://www.rfc-editor.org/rfc/rfc9110)
- [JSON:API Specification](https://jsonapi.org/)
- [Microsoft REST API Guidelines](https://github.com/microsoft/api-guidelines)

## Resilience Patterns

- [Release It! (2nd ed) - Michael Nygard](https://pragprog.com/titles/mnee2/release-it-second-edition/)
- [Azure Cloud Design Patterns](https://learn.microsoft.com/en-us/azure/architecture/patterns/)
- [AWS Architecture Best Practices](https://aws.amazon.com/architecture/)

## Error Handling

- [RFC 7807 - Problem Details for HTTP APIs](https://tools.ietf.org/html/rfc7807)
- [RFC 9457 - Problem Details for HTTP APIs (updated)](https://www.rfc-editor.org/rfc/rfc9457)

## Logging Practices

- [OpenTelemetry Logging Specification](https://opentelemetry.io/docs/specs/otel/logs/)
- [12 Factor App - Logs](https://12factor.net/logs)

## Observability Patterns

- [OpenTelemetry Documentation](https://opentelemetry.io/docs/)
- [Google SRE Book - Monitoring Distributed Systems](https://sre.google/sre-book/monitoring-distributed-systems/)

## Testing Strategy

- [Test Pyramid - Martin Fowler](https://martinfowler.com/articles/practical-test-pyramid.html)
- [Google Testing Blog](https://testing.googleblog.com/)

## Supply Chain Security

- [SLSA Framework](https://slsa.dev/)
- [Sigstore](https://www.sigstore.dev/)
- [NIST SSDF](https://csrc.nist.gov/Projects/ssdf)

## Privacy & Compliance

- [GDPR Official Text](https://gdpr-info.eu/)
- [CCPA Official Text](https://oag.ca.gov/privacy/ccpa)

## Accessibility & i18n

- [WCAG 2.1 Guidelines](https://www.w3.org/WAI/WCAG21/quickref/)
- [MDN Accessibility Guide](https://developer.mozilla.org/en-US/docs/Web/Accessibility)

## CI/CD Pipelines

- [DORA Metrics](https://dora.dev/)
- [Continuous Delivery - Jez Humble](https://continuousdelivery.com/)

## Secrets & Configuration

- [12 Factor App - Config](https://12factor.net/config)
- [HashiCorp Vault Documentation](https://developer.hashicorp.com/vault/docs)

## Distributed Sagas

- [Microservices Patterns - Chris Richardson](https://microservices.io/patterns/data/saga.html)
- [Designing Data-Intensive Applications - Martin Kleppmann](https://dataintensive.net/)

## Database Indexing

- [Use The Index, Luke](https://use-the-index-luke.com/)
- [PostgreSQL Index Documentation](https://www.postgresql.org/docs/current/indexes.html)

---

## Contributing References

When adding references:

| Guideline | Rationale |
|-----------|-----------|
| Prefer official documentation | More stable than blog posts |
| Include RFCs where applicable | Authoritative and versioned |
| One section per guide | Easy to maintain |
| No inline links in guides | Keeps agent context clean |
