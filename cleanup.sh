#!/bin/bash
kubectl delete statefulset redis-primary
kubectl delete statefulset redis-secondary
kubectl delete statefulset redis-sentinel
kubectl delete services redis-primary redis-secondary redis-sentinel
