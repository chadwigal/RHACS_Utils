#!/usr/bin/bash

usage() { echo "Usage: $0 [-i <string>] [-o <string>]" 1>&2; exit 1; }

while getopts ":i:o:" arg; do
    case "${arg}" in
        i)
            i=${OPTARG}
            ;;
        o)
            o=${OPTARG}
            ;;
        *)
            usage
            ;;
    esac
done
shift $((OPTIND-1))

if [ -z "${i}" ] || [ -z "${o}" ]; then
    usage
fi

> ${o}

for RHSA in `cat ${i} | sort | uniq`
do
  for CVE in `curl -s "https://access.redhat.com/hydra/rest/securitydata/csaf/${RHSA}.json" | jq .vulnerabilities[].cve 2> /dev/null`
  do
    CVSS=`curl -s "https://access.redhat.com/hydra/rest/securitydata/csaf/${RHSA}.json" | jq '.vulnerabilities[] | select (.cve | contains('${CVE}'))' | jq .scores[].cvss_v3.baseScore`
    echo "$RHSA:$CVE:$CVSS" >> ${o}
  done
done
