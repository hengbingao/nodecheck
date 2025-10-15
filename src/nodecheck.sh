#!/usr/bin/env bash

partition=${1:-ll} # 默认分区名为 ll

echo "=== JOBS ON ${partition^^} PARTITION ==="

# 打印表头
printf "%-10s %-10s %-20s %-10s %-3s %-10s %-6s %-10s %-10s %-20s\n" \
  "JOBID" "PARTITION" "NAME" "USER" "ST" "TIME" "CPUS" "REQ_MEM" "TIME_LIMIT" "NODELIST(REASON)"

# 获取该分区的所有 job ID
job_ids=$(squeue -p "$partition" -h -o "%i")
for jobid in $job_ids; do
  job_info=$(scontrol show job "$jobid" 2>/dev/null)
  if [ -z "$job_info" ]; then
    continue
  fi
  name=$(echo "$job_info" | awk -F= '/JobName=/{print $2}' | awk '{print $1}')
  user=$(echo "$job_info" | awk -F= '/UserId=/{print $2}' | awk -F'(' '{print $1}')
  state=$(echo "$job_info" | awk -F= '/JobState=/{print $2}' | awk '{print $1}')
  time=$(squeue -j "$jobid" -h -o "%M")
  cpus=$(echo "$job_info" | grep -oP 'cpu=\K[0-9]+')
  mem=$(echo "$job_info" | grep -oP 'mem=\K[^,]*')
  timelimit=$(echo "$job_info" | awk -F= '/TimeLimit=/{print $2}' | awk '{print $1}')
  partition_field=$(echo "$job_info" | awk -F= '/Partition=/{print $2}' | awk '{print $1}')
  reason_or_node=$(squeue -j "$jobid" -h -o "%R")

  printf "%-10s %-10s %-20s %-10s %-3s %-10s %-6s %-10s %-10s %-20s\n" \
    "$jobid" "$partition_field" "$name" "$user" "$state" "$time" "$cpus" "$mem" "$timelimit" "$reason_or_node"
done

echo

# 获取该分区的所有节点
nodes=$(squeue -p "$partition" -h -o "%N" | tr ',' '\n' | sort -u)

if [ -z "$nodes" ]; then
  echo "No nodes found in partition '$partition'"
  exit 0
fi

echo "=== ${partition^^} RESOURCE SUMMARY ==="
for node in $nodes; do
  echo "--- Node: $node ---"

  node_info=$(scontrol show node "$node" 2>/dev/null)
  if [ $? -ne 0 ]; then
    echo "Failed to get node info for $node"
    continue
  fi

  # 提取字段
  state=$(echo "$node_info" | awk -F= '/State=/{print $2}' | awk '{print $1}')
  cpu_alloc=$(echo "$node_info" | grep -oP 'CPUAlloc=\K[0-9]+')
  cpu_total=$(echo "$node_info" | grep -oP 'CPUTot=\K[0-9]+')
  mem_alloc=$(echo "$node_info" | grep -oP 'AllocMem=\K[0-9]+')
  mem_total=$(echo "$node_info" | grep -oP 'RealMemory=\K[0-9]+')
  mem_free=$(echo "$node_info" | grep -oP 'FreeMem=\K[0-9]+')
  load=$(echo "$node_info" | grep -oP 'CPULoad=\K[0-9.]+')

  # 内存单位换算为 GB
  mem_alloc_gb=$((mem_alloc / 1000))
  mem_total_gb=$((mem_total / 1000))
  mem_free_gb=$((mem_free / 1000))
  mem_avail_gb=$((mem_total_gb - mem_alloc_gb))

  echo "State: $state"
  echo "CPUs:  $cpu_alloc/$cpu_total used ($((cpu_total - cpu_alloc)) available)"
  echo "Memory: ${mem_alloc_gb}GB/${mem_total_gb}GB allocated (${mem_avail_gb}GB available)"
  echo "Free Memory: ${mem_free_gb}GB"
  echo "Load: $load"
done
