#!/bin/sh

mkdir temp && cd temp
git clone git@github.com:k3s-io/k3s-ansible.git
cp -r k3s-ansible/roles/* roles
cd ..
rm -rf temp
