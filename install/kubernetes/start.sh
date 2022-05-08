mkdir -p /data/k8s/kubeflow/pipeline/workspace

node=`kubectl get node |grep worker | awk '{print $1}' | head -n 1`
kubectl label node $node train=true cpu=true org=public mysql=true redis=true monitoring=true --overwrite
# 拉取镜像

curl -LO https://dl.k8s.io/release/v1.18.0/bin/linux/amd64/kubectl && chmod +x kubectl  && mv kubectl /usr/bin/
wget https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize%2Fv4.5.1/kustomize_v4.5.1_linux_amd64.tar.gz && tar -zxvf kustomize_v4.5.1_linux_amd64.tar.gz && chmod +x kustomize && mv kustomize /usr/bin/

# 创建命名空间
sh create_ns_secret.sh
# 部署dashboard
kubectl apply -k cube/overlays
kubectl apply -f ingress.yaml

# 本地电脑手动host
echo "在自己的电脑执行以下命令："
echo "sudo echo ${ip} kubeflow.local.com >> /etc/hosts"



