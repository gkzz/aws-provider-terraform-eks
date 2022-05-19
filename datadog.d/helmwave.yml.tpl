version: 0.19.3

repositories:
  - name: datadog
    url: https://helm.datadoghq.com

template:
  gomplate:
    enabled: true
    data:
      sources:
        secret:
          url:
            scheme: aws+sm
            path: 'datadog/apikey2'

.options: &options
  namespace: datadog-agent
  wait: true
  timeout: 300s
  create_namespace: true

releases:
  - name: datadog-agent
    <<: *options
    chart:
      name: https://helm.datadoghq.com
    namespace: datadog-agent
    store:
     targetSystem: linux
    values:
      - vaules-secret.yaml
