#!/bin/bash

helm install --name chrissi-elastic incubator/elastic-stack --set logstash.enabled=false,kibana.env.ELASTICSEARCH_URL=http://chrissi-elastic-elasticsearch-client.default.svc.cluster.local:9200

