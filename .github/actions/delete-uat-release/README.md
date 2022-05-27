# Delete UAT release

Github action to encapsulate the reusable steps required
for deleting an apply PRs UAT release.

## Prerequsites and assumptions:

- github secrets containing kubernetes credentials available
- assumes a certain name for UAT release (see deploy script)

## Workflow example: delete a UAT release when PR on merge

```yml
name: Delete UAT release on PR merge

on:
  pull_request:
    types:
      - closed

  my_job:
    if: github.event.pull_request.merged == true
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Delete UAT release action
        uses: ./.github/actions/delete-uat-release
        with:
          k8s_cluster: ${{ secrets.K8S_CLUSTER }}
          k8s_cluster_cert: ${{ secrets.K8S_CLUSTER_CERT }}
          k8s_namespace: ${{ secrets.K8S_NAMESPACE }}
          k8s_token: ${{ secrets.K8S_TOKEN }}
```
