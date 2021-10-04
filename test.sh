

#!/bin/bash
PACE_API_URL=https://pace.qentinel.com/pace/v4/builds
PACE_API_KEY=ca3f9f15-2db7-499b-aaf6-e74c9022db3c
# Start the build
BUILD=$(curl -sS -d '{"key": "'${PACE_API_KEY}'", "inputParameters": [{"key": "BROWSER", "value": "chrome"}]}' -H "Content-Type: application/json" -X POST ${PACE_API_URL})
echo "${BUILD}"
BUILD_ID=$(echo "${BUILD}" | grep -Po '"id":\K[0-9]+')
if [ -z "${BUILD_ID}" ]; then
  exit 1
fi
echo -n "Executing tests "
STATUS='"executing"'
# Poll every 10 seconds until the build is finished
while [ "${STATUS}" == '"executing"' ]; do
  sleep 10
  RESULTS=$(curl -sS ${PACE_API_URL}/${BUILD_ID}?key=${PACE_API_KEY})
  STATUS=$(echo "${RESULTS}" | grep -Po '"status": *\K"[^"]*"' | head -1)
  echo -n "."
done
echo " done!"
FAILURES=$(echo ${RESULTS} | grep -Po '"failures":\K[0-9]+')
LOG_REPORT_URL=$(echo "${RESULTS}" | grep -Po '"logReportUrl": *\K"[^"]*"')
echo "Report URL: ${LOG_REPORT_URL}"

