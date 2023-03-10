curl -X PATCH \
  $1/core/v1/cycle-test-automated/$2/execution-status \
  -H 'cache-control: no-cache' \
  -H 'content-type: application/json' \
  -d '{ "status": "ENVIRONMENT"}'
docker rm -f test_runner || true
docker run -e TOKEN=$2 -e URL_RESPONSE="$1" --name test_runner -v /$(pwd -W || pwd  -LP):/usr/src/app --volume "//var/run/docker.sock:/var/run/docker.sock" --network host --privileged $4
docker rm -f test_runner
curl -X PATCH \
  $1/core/v1/cycle-test-automated/$2/execution-status \
  -H 'cache-control: no-cache' \
  -H 'content-type: application/json' \
  -d '{ "status": "FINISHED"}'