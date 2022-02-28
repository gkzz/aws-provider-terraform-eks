# Setup Argo CD

- Modify argocd's manifest
  - Ref: [Service Type Load Balancer - Argo CD](https://argo-cd.readthedocs.io/en/stable/getting_started/#service-type-load-balancer)
  - Ref: [Ingress Configuration - Argo CD](https://argo-cd.readthedocs.io/en/stable/operator-manual/ingress/#private-argo-cd-ui-with-multiple-ingress-objects-and-byo-certificate)
```
$ vim argocd.stable.yaml

# 略

2991 ---
2992 apiVersion: v1
2993 kind: Service
2994 metadata:
2995   labels:
2996     app.kubernetes.io/component: server
2997     app.kubernetes.io/name: argocd-server
2998     app.kubernetes.io/part-of: argocd
2999   name: argocd-server
3000 spec:
3001   ports:
3002   - name: http
3003     port: 80
3004     protocol: TCP
3005     targetPort: 8080
3006   - name: https
3007     port: 443
3008     protocol: TCP
3009     targetPort: 8080
3010   selector:
3011     app.kubernetes.io/name: argocd-server
3012 # https://argo-cd.readthedocs.io/en/stable/getting_started/#service-type-load-balancer
3013   type: LoadBalancer  ## <-- Add
```

```
$ vim  argocd.stable.yaml

# 略

3350 ---
3351 apiVersion: apps/v1
3352 kind: Deployment
3353 metadata:
3354   labels:
3355     app.kubernetes.io/component: server
3356     app.kubernetes.io/name: argocd-server
3357     app.kubernetes.io/part-of: argocd
3358   name: argocd-server
3359 spec:
3360   selector:
3361     matchLabels:
3362       app.kubernetes.io/name: argocd-server
3363   template:
3364     metadata:
3365       labels:
3366         app.kubernetes.io/name: argocd-server
3367     spec:
3368       affinity:
3369         podAntiAffinity:
3370           preferredDuringSchedulingIgnoredDuringExecution:
3371           - podAffinityTerm:
3372               labelSelector:
3373                 matchLabels:
3374                   app.kubernetes.io/name: argocd-server
3375               topologyKey: kubernetes.io/hostname
3376             weight: 100
3377           - podAffinityTerm:
3378               labelSelector:
3379                 matchLabels:
3380                   app.kubernetes.io/part-of: argocd
3381               topologyKey: kubernetes.io/hostname
3382             weight: 5
3383 # https://argo-cd.readthedocs.io/en/stable/operator-manual/ingress/#disable-internal-tls
3384 # https://dev.classmethod.jp/articles/eks-argocd-getting-started/
3385       containers:
3386       - command:
3387         - argocd-server
3388         - --insecure ## <-- Add
```

- Create Argo CD's namespace

```
$ kubectl create namespace argocd
$ kubectl apply -f argo.stable.yaml -n argocd
```

- Login Argocd Server

```
$ k get svc  argocd-server -n argocd
NAME            TYPE           CLUSTER-IP       EXTERNAL-IP                                                                    PORT(S)                      AGE
argocd-server   LoadBalancer   10.x.x.x   **************.elb.amazonaws.com   80:32045/TCP,443:30398/TCP   7m46s
$ kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo
<secret>
$ argocd login --insecure ${EXTERNAL-IP}
WARNING: server is not configured with TLS. Proceed (y/n)? y
Username: admin
Password: 
'admin:login' logged in successfully
Context '**************.elb.amazonaws.com' updated
```

- Register a demo app, hello-python
```
$ kubectl create namespace hello-python
$ CONTEXT_NAME=`kubectl config view -o jsonpath='{.current-context}'`
$ echo $CONTEXT_NAME
arn:aws:eks:**********:cluster/gkzz-dev-cluster
$ argocd cluster add $CONTEXT_NAME
INFO[0001] ServiceAccount "argocd-manager" created in namespace "kube-system" 
INFO[0001] ClusterRole "argocd-manager-role" created    
INFO[0001] ClusterRoleBinding "argocd-manager-role-binding" created 
Cluster 'https://**********.eks.amazonaws.com' added
$ argocd cluster list
SERVER                                NAME                                                              VERSION  STATUS MESSAGE
https://**********.eks.amazonaws.com  arn:aws:eks:**********:cluster/gkzz-dev-cluster    Unknown  Cluster has no application and not being monitored.
https://kubernetes.default.svc        in-cluster                                                        Unknown  Cluster has no application and not being monitored.
              
$ argocd repo add git@github.com:gkzz/mycrud-manifest.git \
  --ssh-private-key-path /path/to/my_id_rsa_keyname
repository 'git@github.com:gkzz/mycrud-manifest.git' added

$ argocd app create hello-python \
--repo git@github.com:gkzz/mycrud-manifest.git \
--path manifests/eks/mycrud-django-postgres-docker --dest-server https://kubernetes.default.svc --dest-namespace hello-python \
--revision main --sync-policy automated --auto-prune --self-heal
application 'hello-python' created


$ argocd app list
NAME          CLUSTER                         NAMESPACE     PROJECT  STATUS  HEALTH   SYNCPOLICY  CONDITIONS  REPO                                     PATH                                         TARGET
hello-python  https://kubernetes.default.svc  hello-python  default  Synced  Healthy  Auto-Prune  <none>      git@github.com:gkzz/mycrud-manifest.git  manifests/eks/mycrud-django-postgres-docker  main
```