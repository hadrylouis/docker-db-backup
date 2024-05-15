#!/bin/bash

export AWS_ACCESS_KEY_ID=${DEFAULT_S3_KEY_ID}
export AWS_SECRET_ACCESS_KEY=${DEFAULT_S3_KEY_SECRET}
export AWS_DEFAULT_REGION=${DEFAULT_S3_REGION}
export PARAMS_AWS_ENDPOINT_URL=" --endpoint-url ${DEFAULT_S3_PROTOCOL}://${DEFAULT_S3_HOST}"
export TEMP_PATH="/tmp"

# Check connection to S3
if ! aws s3 ls ${PARAMS_AWS_ENDPOINT_URL} > /dev/null 2>&1; then
    echo -e "\nError: Failed to connect to S3. Please check your connection and try again."
    exit 1
fi

# Filter files from S3
if [ "${DB01_COMPRESSION}" == "zstd" ]; then
    export SOURCE_FILE=".*\.sql.zst$"
else
    export SOURCE_FILE=".*\.sql.${DB01_COMPRESSION}$"
fi

echo -e "--------------------------------------------------"
echo -e "List of all available backup files:"
echo -e "--------------------------------------------------"

BACKUP_FILES=$(aws s3 ls s3://${DEFAULT_S3_BUCKET}/${DEFAULT_S3_PATH}/ ${PARAMS_AWS_ENDPOINT_URL} --recursive | grep -E ${SOURCE_FILE} | awk '{print $4}')
echo "${BACKUP_FILES}"

echo -e "\n--------------------------------------------------"
echo -e "Please enter the name of the file you wish to restore:"
echo -e "--------------------------------------------------"
echo -n "> "
read CHOSEN_FILE

# Check if the chosen file exists
if echo "${BACKUP_FILES}" | grep -q "${CHOSEN_FILE}"; then
    LATEST_FILE=$CHOSEN_FILE
else
    echo -e "\nError: The chosen file does not exist. Please try again."
    exit 1
fi

echo -e "\n--------------------------------------------------"
echo -e "Restoration Summary:"
echo -e "--------------------------------------------------"

echo -e "File to restore: $LATEST_FILE"
echo -e "Restoration location: s3://${DEFAULT_S3_BUCKET}/${DEFAULT_S3_PATH}/"
echo -e "Destination database:"
echo -e "\t - Host: ${DB01_HOST}:${DB01_PORT}"
echo -e "\t - DB Name: ${DB01_NAME}"
echo -e ""
echo -e "With these parameters, are you sure you want to continue? (y/n) "
echo -n "> "
read -p "" -n 1 -r

echo    # (optional) move to a new line
if [[ $REPLY =~ ^[Yy]$ ]]
then
    echo -e "\n--------------------------------------------------"
    echo -e "Restoration in progress..."
    echo -e "--------------------------------------------------"
    aws s3 cp s3://${DEFAULT_S3_BUCKET}/${LATEST_FILE} ${TEMP_PATH}/${LATEST_FILE} ${PARAMS_AWS_ENDPOINT_URL}
    restore ${TEMP_PATH}/${LATEST_FILE} ${DB01_TYPE} ${DB01_HOST} ${DB01_NAME} ${DB01_USER} ${DB01_PASS} ${DB01_PORT}
else
    echo -e "\n--------------------------------------------------"
    echo -e "Restoration cancelled."
    echo -e "--------------------------------------------------"
fi