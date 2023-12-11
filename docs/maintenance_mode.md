## Maintenance mode

A conditional catchall routes exists in `routes.rb`. This directs all routes requested to the `pages#servicedown` controller and view. To activate the conditional route you must provide the app server with MAINTENANCE_MODE=true. When supplied via the helm values.yml files it must be supplied as a string "true".

```bash
# activate maintenance mode locally
MAINTENANCE_MODE=true rails s
```

You can deploy the app in maintenance mode for the hosted environments by setting it to enabled: "true" in the relevant values.yml files

```yml
# example values-uat.yaml
maintenance_mode:
  enabled: "true"
```

To apply via circleCI:

- commit the above change and push to github
- run through circleCI and deploy to the relevant environment
- to take site out of maintenance you would have to commit the reverse and redeploy via circleCI
