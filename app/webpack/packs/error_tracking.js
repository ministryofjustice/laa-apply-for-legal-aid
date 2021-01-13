import * as Sentry from '@sentry/browser';
import { Integrations } from "@sentry/tracing";

console.log(process.env.SENTRY_DSN)

Sentry.init({ dsn: process.env.SENTRY_DSN,
              integrations: [new Integrations.BrowserTracing()],
            });

window.Sentry = Sentry
