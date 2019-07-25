#
# Clean up dying pods
#
pods=$( kubectl get pods | grep -v Running | tail -n +2 | awk -F " " '{print $1}' )
for pod in $pods;
do
    kubectl delete pod $pod --force
done

