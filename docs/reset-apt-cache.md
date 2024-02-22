# Reset Apt cache
If there are issues with apt pulling packages, it is sometimes caused by caching issues.

This will often manifest as a 503 error when running apt update.

When this happens the following prodecure can be used to clear the cache and restart the caching proxy service.

## 1. Delete the cached data
**From erisxdl1 as root**
```
cd /data/erisxd/volumes/apt-cacher-ng
rm -rf ./*
```

## 2. Restart the apt-cacher-ng service
** From erisxdl1 as dgxadmin**

Get the Pod name
```
kubectl get pods -n default |grep apt-cacher
```

Delete the pod
```
kubectl delete pod -n default <POD_NAME_FROM_PREVIOUS_COMMAND>
```

Verify the pod restarts
```
kubectl get pods -n default |grep apt-cacher
```

## 3. Verify rebuilt cache
**From erisxdl1 as root**
```
ls -l /data/erisxd/volumes/apt-cacher-ng
```

Once the cache is restarted, try to run the apt update again

