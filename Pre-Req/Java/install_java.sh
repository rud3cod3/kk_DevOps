#!/bin/bash

set -e

# Download the java first
cd /opt
wget https://download.java.net/java/GA/jdk20/bdc68b4b9cbc4ebcb30745c85038d91d/36/GPL/openjdk-20_linux-aarch64_bin.tar.gz
tar -xvf *.tar.gz
cd /openjdk20/bin
java --version
export PATH=$PATH:/opt/openjdk20/bin
java --version
