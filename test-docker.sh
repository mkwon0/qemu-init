#!/bin/bash

NUM_CONT=1

docker stop $(docker ps -aq) && docker rm $(docker ps -aq)

cat /proc/swaps
for CONT_ID in $(seq 1 $NUM_CONT); do
  docker run -itd --privileged --oom-kill-disable=true \
        --name stress$CONT_ID --memory="30m" --memory-swap="60m" --memory-swappiness="80" \
        --memory-swapfile "none" --entrypoint "/bin/bash" progrium/stress
  DID=$(docker inspect stress${CONT_ID} --format {{.Id}})
  cat /sys/fs/cgroup/memory/docker/$DID/memory.swapfile
done

#echo "start test!!"
#for CONT_ID in $(seq 1 $NUM_CONT); do
#  docker exec stress${CONT_ID} bash -c "/usr/bin/stress --vm 1 --vm-bytes 30m" &
#done
