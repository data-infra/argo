# 机器/k8s环境/ceph环境准备  
机器环境准备：准备docker，准备rancher，部署k8s。如果已经有可以忽略，没有可以参考rancher/readme.md  

如果使用tke选择独立集群(非托管集群)，这样方便自行管理api server启动参数，部署istio

# 单机测试

在单机上将k8s的kubeconfig文件保存为
cube-studio/install/kubernetes/config
```
cd cube-studio/install/kubernetes/
sh start.sh
```
[单机部署参考视频](https://docker-76009.sz.gfp.tencent-cloud.com/kubeflow/install_standalone.mp4)
 
# 通过label进行机器管理  
开发训练服务机器管理：
- 对于cpu的train/notebook/service会选择cpu=true的机器  
- 对于gpu的train/notebook/service会选择gpu=true的机器  

- 训练任务会选择train=true的机器  
- notebook会选择notebook=true的机器  
- 服务化会选择service=true的机器  
- 不同项目的任务会选择对应org=xx的机器。默认为org=public 
- 可以通过gpu-type=xx表示gpu的型号
  
控制器机器管理：
- mysql=true 部署mysql服务的机器
- redis=true 部署mysql服务的机器
- kubeflow-dashobard=true 部署cube服务的机器

# 分布式存储

目前机器学习平台依赖强io性能的分布式存储。  建议使用ssd的ceph作为分布式存储。并注意配置好开机自动挂载避免在机器重启后挂载失效

 ！！！重要：分布式文件系统需要挂载到每台机器的/data/k8s/下面，当然也可以挂载其他目录下，以软链的形式链接到/data/k8s/下 

需要每台机器都有对应的目录/data/k8s为分布式存储目录
```bash  
mkdir -p /data/k8s/kubeflow/pipeline/workspace  
```  
平台pvc会使用这些分布式存储目录下的subpath，所以如果你是rancher部署k8s集群，需要在kubelet容器中挂载主机的/data/k8s/目录到kubelet容器的/data/k8s/目录。
rancher修改kubelet容器挂载目录(选中集群-升级-编辑yaml)
```
    kubelet:
      extra_binds:
        - '/data/k8s:/data/k8s'
```
  

```bash  
修改里面的docker hub拉取账号密码  
sh create_ns_secret.sh  
```  
  
# 部署k8s-dashboard  
新版本的k8s dashboard 可以直接开放免登陆的http，且可以设置url前缀代理  
```bash  
kubectl apply -f dashboard/v2.2.0-cluster.yaml  
kubectl apply -f dashboard/v2.2.0-user.yaml  
```  

# 部署元数据组件mysql  
参考mysql/readme.md  

# 部署缓存组件redis  
参考redis/readme.md  
  

# 部署 管理平台  


组件说明  
 - cube/base/deploy.yaml为myapp的前后端代码  
 - cube/base/deploy-schedule.yaml 为任务产生器  
 - cube/base/deploy-worker.yaml 为任务执行器  
 - cube/base/deploy-watch.yaml 任务监听器  

配置文件说明  
 - cube/overlays/config/entrypoint.sh 镜像启动脚本  
 - cube/overlays/config/config.py  配置文件，需要将其中的配置项替换为自己的  
  
部署入口  
cube/overlays/kustomization.yml    
  
修改kustomization.yml中需要用到的环境变量。例如HOST为平台的域名，需要指向istio ingressgate的服务(本地调试可以写入到/etc/hosts文件中)  
  
部署执行命令  
```bash  
为部署控制台容器的机器添加lable,  kubeflow-dashboard=true
kubectl apply -k cube/overlays  
```  
  
## 部署pv-pvc.yaml  
  
```bash  
kubectl create -f pv-pvc-infra.yaml  
kubectl create -f pv-pvc-pipeline.yaml  
```  

# 部署平台入口  
```bash  
# 创建新的账号需要  
kubectl apply -f sa-rbac.yaml          
# 修改并创建ingress。需要将其中的管理平台的域名批量修改为平台的域名
kubectl apply -f ingress.yaml  
```  
  

# 版本升级
数据库升级，数据库记录要批量添加默认值到原有记录上，不然容易添加失败


