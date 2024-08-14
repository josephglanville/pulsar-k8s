Pulsar k8s demo
===============

Sets up Pulsar w/TLS and token authentication along with an example CDC connector using k8s managed secrets for the Pulsar source.
This is entirely setup using k8s operators so the entire state is declaratively managed.

## Requirements
- docker
- helm
- kind
- kubectx

## Running

First build the image, this is needed to work around: https://github.com/datastax/kaap/issues/177
```bash
$ docker buildx build -t apachepulsar/pulsar-jpg:3.3.1 - < Dockerfile
```

Then just run `up.sh` to bootstrap the cluster using `kind`
```
$ ./up.sh
```

Once the cluster has settled you can check the state of the source with:
```bash
$ kubectl get pulsarsources
```
You should see the source is ready:
```
NAME       RESOURCE_NAME   GENERATION   OBSERVED_GENERATION   READY
postgres   postgres        1            1                     Tru
```

You can consume the messages produced by the Debezium connector like so:
```bash
$ kubectl exec -it $(kubectl get pods | grep pulsar-bastion | awk '{print $1}') -- bin/pulsar-client consume -s "sub-users" public/default/dbserver1.public.users -n 0 -p Earliest
```

This will create a new subscription `sub-users` that will consume every message from the start of the topic, which in this case will include the Debezium snapshot.

While the consumer is still running in another terminal you can insert more records into the database:

```bash
exec -it postgres-cluster-1 -c postgres -- psql appdb -c "INSERT INTO users (hash_firstname, hash_lastname, gender) VALUES (md5(RANDOM()::TEXT), md5(RANDOM()::TEXT), CASE WHEN RANDOM() < 0.5 THEN 'male' ELSE 'female' END);"
```
