#!/bin/sh

DKIM_DISABLE=${DKIM_DISABLE?Missing env var DKIM_DISABLE}
TX_SMTP_RELAY_MYHOSTNAME=${TX_SMTP_RELAY_MYHOSTNAME?Missing env var TX_SMTP_RELAY_MYHOSTNAME}
DKIM_CANONICALIZATION=${DKIM_CANONICALIZATION?Missing env var DKIM_CANONICALIZATION}
DKIM_SELECTOR=${DKIM_SELECTOR?Missing env var DKIM_SELECTOR}
TX_SMTP_RELAY_NETWORKS=${TX_SMTP_RELAY_NETWORKS:-10.0.0.0/8,127.0.0.0/8,172.17.0.0/16,192.0.0.0/8}


# Validate DKIM_DISABLE value
if [ "$DKIM_DISABLE" != "true" ] && [ "$DKIM_DISABLE" != "false" ]; then
  echo "Error: DKIM_DISABLE must be 'true' or 'false'."
  exit 1
fi

echo "===================================="
echo "====== Setting configuration OPENDKIM======="
echo "DKIM_DISABLE              -  ${DKIM_DISABLE}"
echo "TX_SMTP_RELAY_MYHOSTNAME  -  ${TX_SMTP_RELAY_MYHOSTNAME}"
echo "DKIM_CANONICALIZATION     -  ${DKIM_CANONICALIZATION}"
echo "DKIM_SELECTOR             -  ${DKIM_SELECTOR}"
echo "TX_SMTP_RELAY_NETWORKS    -  ${TX_SMTP_RELAY_NETWORKS}"
echo "===================================="

# DKIM
if [ "$DKIM_DISABLE" = "false" ]; then
  echo ">> Enable DKIM support"
  
  # Set default canonicalization if not set
  if [ -z "$DKIM_CANONICALIZATION" ]; then
    DKIM_CANONICALIZATION="simple"
  fi
  echo 'RequireSafeKeys False' >> /etc/opendkim/opendkim.conf
  sed -i "s/Canonicalization.*/Canonicalization $DKIM_CANONICALIZATION/g" /etc/opendkim/opendkim.conf
  sed -i "s/Domain.*/Domain $TX_SMTP_RELAY_MYHOSTNAME/g" /etc/opendkim/opendkim.conf
  sed -i "s/KeyFile.*/KeyFile \/etc\/opendkim\/keys\/dkim.key/g" /etc/opendkim/opendkim.conf
  sed -i "s/Selector.*/Selector $DKIM_SELECTOR/g" /etc/opendkim/opendkim.conf
  sed -i "s|# InternalHosts.*|InternalHosts $TX_SMTP_RELAY_NETWORKS|g" /etc/opendkim/opendkim.conf
fi

/usr/sbin/opendkim -D -f -x /etc/opendkim/opendkim.conf