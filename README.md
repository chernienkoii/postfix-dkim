# Postfix relay running in Kubernetes
This repository has an example of a postfix relay running in Kubernetes using a helm chart.

## Build Docker image
You can build the Docker image locally
```bash
# For local build
docker build -t test/postfix-relay:0.1 .

# Multi arch build and push
docker buildx build --platform linux/amd64,linux/arm64 -t test/postfix-relay:0.1  --push .
```

## Run locally with Docker
Run the postfix relay locally for testing
```bash
# Need to set SMTP connection details
export SMTP=""
export USERNAME_TEST=<your smtp username>
export PASSWORD_TEST=<your smtp password>

# Optional custom configuration to add/override in /etc/postfix/main.cf (delimited by a ";")
export POSTFIX_CUSTOM_CONFIG="key1 = value1;key2 = value2;key3 = value3"

# Set list of allowed networks
export TX_SMTP_RELAY_NETWORKS='10.0.0.0/8,127.0.0.0/8,172.17.0.0/16,192.0.0.0/8'

docker run --rm -d --name postfix-relay -p 25:25 \
	-e TX_SMTP_RELAY_HOST="" \
	-e TX_SMTP_RELAY_MYHOSTNAME=my.local \
	-e TX_SMTP_RELAY_USERNAME=${USERNAME_TEST} \
	-e TX_SMTP_RELAY_PASSWORD=${PASSWORD_TEST} \
	-e TX_SMTP_RELAY_NETWORKS=${TX_SMTP_RELAY_NETWORKS} \
	-e POSTFIX_CUSTOM_CONFIG="${POSTFIX_CUSTOM_CONFIG}" \
	test/postfix-relay:0.1
```

### Test sending mail
1. Connect to running container on port 2525
```bash
telnet localhost 25
```

2. Edit the following with your details and paste in your terminal
```bash
helo localhost
mail from: noreply@example.com
rcpt to: you@your.co
data
Subject: Subject here...
The true story of swans singing Pink Floyd. 
.
quit
```

3. You should see the following
```bash
220 tx-smtp-relay.example.com ESMTP Postfix
helo localhost
250 tx-smtp-relay.example.com
mail from: noreply@example.com
250 2.1.0 Ok
rcpt to: you@your.co
250 2.1.5 Ok
data
354 End data with <CR><LF>.<CR><LF>
Subject: Subject here...
The true story of swans singing Pink Floyd. 
.
250 2.0.0 Ok: queued as 982FF53C
quit
221 2.0.0 Bye
Connection closed by foreign host
```

4. Check the inbox of `you@your.co` and see you got the email.


## Deploy Helm Chart
The Helm Chart in [helm/postfix](helm/postfix) directory can be used to deploy the postfix-relay into your Kubernetes cluster.

Create a `custom-values.yaml` with the configuration details
```yaml
dkim:
  disable: false
  canonicalization: "simple"
  selector: "default"
smtp:
  relayHost: ""
  relayMyhostname: <your smtp hostname>
  relayUsername: <your smtp username>
  relayPassword: <your smtp password>
  relayNetworks: '10.0.0.0/8,127.0.0.0/8,172.17.0.0/16,192.0.0.0/8'
```

Deploy postfix
```bash
helm upgrade --install postfix-relay helm/postfix -f custom-values.yaml
```

### Postfix Metrics exporter
An optional postfix-exporter sidecar can be deployed for exposing postfix metrics. This is using the work from https://github.com/kumina/postfix_exporter.

To enable the exporter sidecar, update your `custom-values.yaml` file and **add**
```yaml
# Enable the postfix-exporter sidecar
exporter:
  enabled: true

# Enable a ServiceMonitor object for Prometheus scraping
serviceMonitor:
  enabled: true
```

Deploy postfix
```bash
helm upgrade --install postfix-relay helm/postfix -f custom-values.yaml
```

