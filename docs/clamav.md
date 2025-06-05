# ClamAV setup

ClamAV is used to make sure uploaded files do not contain any malware.
If you are on Mac, ClamAV would have been installed by running `bin/setup`

## Local steup

Run `bin/setup` to, amongst other things, install clamav on a mac. You will be prompted for a password

On Ubuntu you can install it with:
```
sudo apt-get install clamav clamav-daemon -y
sudo freshclam
sudo /etc/init.d/clamav-daemon start

# You may also need to run:
sudo apt install clamdscan
```

## Hosted setup

Hosted environments implement the ClamAV anti-virus software through a combination of

- a deployment to generate one or more pods in which a custom LAA image of ClamAV is containerised.
- a service that exposes the ClamAV container over TCP
- a persistentvolumeclaim (pvc) to persist the ClamAV "virus signature" database for sharing between ClamAV container replicas
- a volumeMount that exposes the pvc to the ClamAV container as a filesystem volume
- a configmap used by the web/app containers to configure/point their local ClamAV CLI at the containerised ClamAV installation

### Communication between our components
The ClamAV pod or pods contain a single container each. This container uses a [custom ClamAV image maintained by the LAA](https://github.com/ministryofjustice/clamav-docker/pkgs/container/clamav-docker%2Flaa-clamav). The container opens ports 3310 (default for ClamAV). A separate service object exposes this container's ports over TCP. The service does not need to explicitly expose an IP within the cluster (`ClusterIP: None`) nor a specific port (see `zombie-port`). This is because the traffic is within the cluster (and its namespace) so TCP can be used instead of HTTP. The service therefore exposes a zombie-port of 1234 simply to allow TCP to the container. The container already opens port 3310 so no further config is needed in that respect. Note that the service is associated with the clamav pod via its `spec.selector.service` metadata config, as common for all service/deployments.

The web container (deployment/pod) is configured to communicate with the ClamAV pod on its internal cluster location over TCP on port 3310

```sh
  TCPSocket 3310
  TCPAddr  <service-name>.<namespace>.svc.cluster.local
```

This configuration is generated for each web/app pod containter using a `configMap`. This configMap creates a file called `clamd.conf` that is mounted by the web pods at the default/typical ClamAV filesystem location of `/etc/clamav`. The file is therefore generated and available in each web pod as `/etc/clamav/clamd.conf`.

> [!NOTE]
> This file path is explictly configured in the pod as `CLAMD_CONF_FILENAME`. This is passed to `clamdscan` by the code that scans uploaded files - see `app/services/malware_scanner.rb`. It is worth noting that for hosted environments this is not strictly necessary as the config file is in the default location in any event. Local setup however requires the config file, `config/clamd.local.conf`, to be passed explicitly.

### Virus definition database updates
The ClamAV pod mounts a persistent volume at ClamAV's default location (`/var/lib/clamav`) for its signature database (virus definitions). This means we share the same set of virus definitions between all clamav pods and it therefore need only be refreshed once for all clamav replicas to be up to date. We supply a refresh period, in hours, via the `.Values.clamav.freshclamCheck`. A mirror url is also supplied, pointing to an LAA hosted clamav mirror for updating the virus definitions. This is configured using the `.Values.clamav.mirror`.

> [!NOTE]
> A custom/private mirror is used because the ClamAV mirrors throttle excessive numbers of requests. The mirror provides an unthrottled source database only used by the LAA alone (needs verification?!).

It is worth noting that the `accessModes` rule used for the ClamAV PVC is `ReadWriteOnce`. This is the most suitable and supported mode for kubernetes and AWS - `ReadWriteMany` is not supported. This [access mode](https://kubernetes.io/docs/concepts/storage/persistent-volumes/#access-modes) means the PVC can only be mounted by pods in same node of the cluster. We therefore use a `podAffinity` rule in the ClamAV deployment to ensure clamav pods are always using the same node.

> [!CAUTION] Affinity rules are required because consuming pods could be replaced during deployment and these new pods could be assigned to a different node from
> old pods or other new replica pods. This could therefore result in a "Multi-Attach error for Volume" error during deployment, and a failed deployment of one or more ClamAV pods.


### A note on further customisation
If further custom configuration of ClamAV is required then a configMap for the ClamAV deployment could be used.

The configMap might look something like:



```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ .Release.Name }}-clamav-custom-configuration
  namespace: {{ .Release.Namespace }}
data:
  clamd.conf: |-
    LogTime yes
    LogClean yes
    LogSyslog no
    LogVerbose yes
    DatabaseDirectory /var/lib/clamav
    TCPSocket 3310
    Foreground yes
    MaxScanSize {{.Values.clamav.limits.scanSize}}M
    MaxFileSize {{.Values.clamav.limits.fileSize}}M

    #  Close the connection when the data size limit is exceeded.
    #  The value should match your MTA's limit for a maximum attachment size.
    #  Default: 25M
    StreamMaxLength {{.Values.clamav.limits.scanSize}}M

    # Maximum length the queue of pending connections may grow to.
    # Default: 200
    MaxConnectionQueueLength {{.Values.clamav.limits.connectionQueueLength}}

    # Maximum number of threads running at the same time.
    # Default: 10
    MaxThreads {{.Values.clamav.limits.maxThreads}}

    # This option specifies how long to wait (in milliseconds) if the send buffer
    # is full.
    # Keep this value low to prevent clamd hanging.
    #
    # Default: 500
    SendBufTimeout {{.Values.clamav.limits.sendBufTimeout}}

  freshclam.conf: |
    LogTime yes
    LogVerbose yes
    NotifyClamd /etc/clamav/clamd.conf
    Checks {{ .Values.clamav.freshclamCheck }}
    LogSyslog no
    DatabaseOwner clam
    # This option allows you to easily point freshclam to private mirrors.
    # If PrivateMirror is set, freshclam does not attempt to use DNS
    # to determine whether its databases are out-of-date, instead it will
    # use the If-Modified-Since request or directly check the headers of the
    # remote database files. For each database, freshclam first attempts
    # to download the CLD file. If that fails, it tries to download the
    # CVD file. This option overrides DatabaseMirror, DNSDatabaseInfo
    # and ScriptedUpdates. It can be used multiple times to provide
    # fall-back mirrors.
    # Default: disabled
    PrivateMirror http://{{ .Values.clamav.mirror }}
```
_Taken from [home office clamav helm charts](https://github.com/UKHomeOffice/clamav-http/blob/master/charts/clamav/templates/clamav-configmap.yaml)_


This configMap would then be used by the ClamAV deployment itself, and might look something like:


```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ template "apply-for-legal-aid.fullname" . }}-clamav
  .........
  spec:
    .........
    template:
      .........
      containers:
        - name: clamav
          image: ghcr.io/ministryofjustice/clamav-docker/laa-clamav:latest
          imagePullPolicy: Always
          ports:
            - containerPort: 3310
              protocol: TCP
          volumeMounts:
            .........
            - name: clamav-custom-configuration-volume
              mountPath: /etc/clamav
      .........
      volumes:
      - name: clamav-custom-configuration-volume
        configMap:
          name: {{ .Release.Name }}-clamav-custom-configuration

```













