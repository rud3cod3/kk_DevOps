# Kubernetes is an Orchestration Tool
# Docker (or container engines) provide Containerization
# 
# -----------+
# Components |
# -----------+
#
# API Server
# etcd
# Kubelet
# Container Runtime
# Controller
# Scheduler
#
#
# Something from ppt: 
#
# +--------------------+    +-----------------------+    +-----------------------+
# | </> kube-apiserver |    | </> kubelet	    |    | </> kubelet		 |
# | etcd	       |    |			    |    | </> kube-apiserver	 |
# | node-controller    |    |			    |    | etcd 		 |
# | replica-controller |    | container runtime	    |    | node-controller       |
# +--------------------+    +-----------------------+    | replica-controller    |
# 	Master			  Worker Node		 | container runtime     |
#							 +-----------------------+
#							 	Minikube
#
# -------------------+
# Installing kubectl |
# -------------------+
#
#```bash
#curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
#
#chmod u+x ./kubectl
#
#sudo mv ./kubectl /usr/local/bin/
#
#kubectl version --client
#```
#
##
# ---------------------+
## Installing minicube |
# ---------------------+
#
#
