scloud@stg-master02:~/devops-mcc/1.stg/2.moss-db/1.postgres-service$ ka -f 1.sts.yaml 
The request is invalid: patch: Invalid value: "map[metadata:map[annotations:map[kubectl.kubernetes.io/last-applied-configuration:{\"apiVersion\":\"apps/v1\",\"kind\":\"StatefulSet\",\"metadata\":{\"annotations\":{},\"name\":\"postgres\",\"namespace\":\"mcc\"},\"spec\":{\"replicas\":2,\"selector\":{\"matchLabels\":{\"app\":\"postgres\"}},\"serviceName\":\"postgres-headless\",\"template\":{\"metadata\":{\"labels\":{\"app\":\"postgres\"}},\"spec\":{\"containers\":[{\"env\":[{\"name\":\"MY_POD_NAME\",\"valueFrom\":{\"fieldRef\":{\"fieldPath\":\"metadata.name\"}}},{\"name\":\"REPMGR_NODE_NAME\",\"value\":\"$(MY_POD_NAME)\"},{\"name\":\"REPMGR_NODE_NETWORK_NAME\",\"value\":\"$(MY_POD_NAME).postgres-headless.mcc.svc.cluster.local\"}],\"envFrom\":[{\"configMapRef\":{\"name\":\"postgres\"}},{\"secretRef\":{\"name\":\"postgres\"}}],\"image\":\"docker.io/library/mcc-postgresql-repmgr:16.3.0\",\"imagePullPolicy\":\"IfNotPresent\",\"livenessProbe\":{\"exec\":{\"command\":[\"bash\",\"-ec\",\"PGPASSWORD=$POSTGRESQL_PASSWORD psql -w -U $POSTGRESQL_USERNAME -d $POSTGRESQL_DATABASE -h 127.0.0.1 -p 5432 -c \\\"SELECT 1\\\"\"]},\"failureThreshold\":6,\"periodSeconds\":10,\"timeoutSeconds\":5},\"name\":\"postgresql\",\"readinessProbe\":{\"exec\":{\"command\":[\"bash\",\"-ec\",\"exec pg_isready -U $POSTGRESQL_USERNAME -h 127.0.0.1 -p 5432\\n[ -f /opt/bitnami/postgresql/tmp/.initialized ] || [ -f /bitnami/postgresql/.initialized ]\\n\"]},\"failureThreshold\":3,\"initialDelaySeconds\":10,\"periodSeconds\":10,\"successThreshold\":1,\"timeoutSeconds\":5},\"startupProbe\":{\"exec\":{\"command\":[\"bash\",\"-ec\",\"PGPASSWORD=$POSTGRESQL_PASSWORD psql -w -U $POSTGRESQL_USERNAME -d $POSTGRESQL_DATABASE -h 127.0.0.1 -p 5432 -c \\\"SELECT 1\\\"\"]},\"failureThreshold\":60,\"initialDelaySeconds\":10,\"periodSeconds\":30,\"timeoutSeconds\":5},\"volumeMounts\":[{\"mountPath\":\"/bitnami/postgresql\",\"name\":\"postgres-data\"},{\"mountPath\":\"/etc/localtime\",\"name\":\"time-zone\"},{\"mountPath\":\"/dev/shm\",\"name\":\"dshm\"}]}],\"nodeSelector\":{\"role\":\"db\"},\"volumes\":[{\"hostPath\":{\"path\":\"/usr/share/zoneinfo/Asia/Ho_Chi_Minh\"},\"name\":\"time-zone\"},{\"emptyDir\":{\"medium\":\"Memory\",\"sizelimit\":\"1Gi\"},\"name\":\"dshm\"}]}},\"updateStrategy\":{\"type\":\"OnDelete\"},\"volumeClaimTemplates\":[{\"metadata\":{\"name\":\"postgres-data\"},\"spec\":{\"accessModes\":[\"ReadWriteOnce\"],\"resources\":{\"requests\":{\"storage\":\"100Gi\"}},\"storageClassName\":\"local-path\"}}]}}\n]] spec:map[template:map[spec:map[]] volumeClaimTemplates:[map[metadata:map[name:postgres-data] spec:map[accessModes:[ReadWriteOnce] resources:map[requests:map[storage:100Gi]] storageClassName:local-path]]]]]": strict decoding error: unknown field "spec.template.spec.volumes[1].emptyDir.sizelimit"


The StatefulSet "postgres" is invalid: spec: Forbidden: updates to statefulset spec for fields other than 'replicas', 'ordinals', 'template', 'updateStrategy', 'persistentVolumeClaimRetentionPolicy' and 'minReadySeconds' are forbidden


Warning: resource statefulsets/postgres is missing the kubectl.kubernetes.io/last-applied-configuration annotation which is required by kubectl apply. kubectl apply should only be used on resources created declaratively by either kubectl create --save-config or kubectl apply. The missing annotation will be patched automatically.
The StatefulSet "postgres" is invalid: spec: Forbidden: updates to statefulset spec for fields other than 'replicas', 'ordinals', 'template', 'updateStrategy', 'persistentVolumeClaimRetentionPolicy' and 'minReadySeconds' are forbidden

apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: postgres
  namespace: mcc
spec:
  replicas: 2
  updateStrategy:
    type: OnDelete
  selector:
    matchLabels:
      app: postgres
  serviceName: postgres-headless
  template:
    metadata:
      labels:
        app: postgres
    spec:
      nodeSelector:
        role: db
      containers:
        - name: postgresql
          image: docker.io/library/mcc-postgresql-repmgr:16.3.0
          imagePullPolicy: IfNotPresent
          envFrom:
            - configMapRef:
                name: postgres
            - secretRef:
                name: postgres
          env:
            - name: MY_POD_NAME
              valueFrom:
                fieldRef:
                  fieldPath: metadata.name
            - name: REPMGR_NODE_NAME
              value: "$(MY_POD_NAME)"
            - name: REPMGR_NODE_NETWORK_NAME
              value: "$(MY_POD_NAME).postgres-headless.mcc.svc.cluster.local"
          volumeMounts:
            - name: postgres-data
              mountPath: /bitnami/postgresql
            - name: time-zone
              mountPath: /etc/localtime
            - name: dshm
              mountPath: /dev/shm
          startupProbe:
            exec:
              command:
                - bash
                - -ec
                - 'PGPASSWORD=$POSTGRESQL_PASSWORD psql -w -U $POSTGRESQL_USERNAME -d $POSTGRESQL_DATABASE -h 127.0.0.1 -p 5432 -c "SELECT 1"'
            initialDelaySeconds: 10
            periodSeconds: 30
            timeoutSeconds: 5
            failureThreshold: 60
          livenessProbe:
            exec:
              command:
                - bash
                - -ec
                - 'PGPASSWORD=$POSTGRESQL_PASSWORD psql -w -U $POSTGRESQL_USERNAME -d $POSTGRESQL_DATABASE -h 127.0.0.1 -p 5432 -c "SELECT 1"'
            periodSeconds: 10
            timeoutSeconds: 5
            failureThreshold: 6
          readinessProbe:
            exec:
              command:
                - bash
                - -ec
                - |
                  exec pg_isready -U $POSTGRESQL_USERNAME -h 127.0.0.1 -p 5432
                  [ -f /opt/bitnami/postgresql/tmp/.initialized ] || [ -f /bitnami/postgresql/.initialized ]
            initialDelaySeconds: 10
            periodSeconds: 10
            timeoutSeconds: 5
            successThreshold: 1
            failureThreshold: 3
      volumes:
        - name: time-zone
          hostPath:
            path: /usr/share/zoneinfo/Asia/Ho_Chi_Minh          
        - name: dshm
          emptyDir:
            medium: Memory
            sizeLimit: 1Gi
  volumeClaimTemplates:
    - metadata:
        name: postgres-data
      spec:
        accessModes:
          - "ReadWriteOnce"
        storageClassName: local-path
        resources:
          requests:
            storage: "100Gi"
