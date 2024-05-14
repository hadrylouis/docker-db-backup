#!/bin/bash

export AWS_ACCESS_KEY_ID=${DEFAULT_S3_KEY_ID}
export AWS_SECRET_ACCESS_KEY=${DEFAULT_S3_KEY_SECRET}
export AWS_DEFAULT_REGION=${DEFAULT_S3_REGION}
export PARAMS_AWS_ENDPOINT_URL=" --endpoint-url ${DEFAULT_S3_PROTOCOL}://${DEFAULT_S3_HOST}"
export SOURCE_FILE="pgsql_.*\.sql.zst$"
export TEMP_PATH="/tmp"

# List all backup files
echo "Voici tous les fichiers de sauvegarde disponibles :"
aws s3 ls s3://${DEFAULT_S3_BUCKET}/${DEFAULT_S3_PATH}/ ${PARAMS_AWS_ENDPOINT_URL} --recursive | grep -E ${SOURCE_FILE} | awk '{print $4}'

# Ask the user to choose a file
echo "Veuillez entrer le nom du fichier que vous souhaitez restaurer :"
read CHOSEN_FILE

# Set the chosen file as the latest file
LATEST_FILE=$CHOSEN_FILE

# Display a summary of the restore parameters
echo "Vous avez choisi de restaurer le fichier suivant : $LATEST_FILE"

# Display a detailed summary of the restore parameters
echo "Résumé de la restauration :"
echo "Fichier à restaurer : $LATEST_FILE"
echo "Emplacement de la restauration : s3://${DEFAULT_S3_BUCKET}/${DEFAULT_S3_PATH}/"
echo "Base de données de destination : ${DB01_NAME} sur ${DB01_HOST}:${DB01_PORT}"

# Ask the user for confirmation
read -p "Avec ces paramètres, êtes-vous sûr de vouloir continuer ? (y/n) " -n 1 -r

echo    # (optional) move to a new line
if [[ $REPLY =~ ^[Yy]$ ]]
then
    # Proceed with the restore
    echo "Restauration en cours..."
    aws s3 cp s3://${DEFAULT_S3_BUCKET}/${LATEST_FILE} ${TEMP_PATH}/${LATEST_FILE} ${PARAMS_AWS_ENDPOINT_URL}
    restore ${TEMP_PATH}/${LATEST_FILE} ${DB01_TYPE} ${DB01_HOST} ${DB01_NAME} ${DB01_USER} ${DB01_PASS} ${DB01_PORT}
else
    echo "Restauration annulée."
fi