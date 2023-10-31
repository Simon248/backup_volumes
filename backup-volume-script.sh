#!/bin/sh

VOLUME_NAME=$1
BACKUP_PATH=$2

if [ -z "$VOLUME_NAME" ]; then
  echo "Le nom du volume est requis."
  exit 1
fi

if [ -z "$BACKUP_PATH" ]; then
  echo "Le chemin de sauvegarde est requis."
  exit 1
fi

# Identifier et stopper tous les conteneurs qui utilisent le volume
CONTAINERS=$(docker ps -q --filter volume=$VOLUME_NAME)
if [ ! -z "$CONTAINERS" ]; then
  echo "Arrêt des conteneurs qui utilisent le volume $VOLUME_NAME..."
  docker stop $CONTAINERS
fi

echo "Démarrage de la sauvegarde du volume $VOLUME_NAME..."
docker run --rm -v $VOLUME_NAME:/data -v $BACKUP_PATH:/backup alpine tar czf /backup/backup_$VOLUME_NAME_$(date +"%Y%m%d_%H%M%S").tar.gz -C /data ./
echo "Sauvegarde terminée. Le backup est stocké dans $BACKUP_PATH"

# Redémarrer les conteneurs
if [ ! -z "$CONTAINERS" ]; then
  echo "Redémarrage des conteneurs..."
  docker start $CONTAINERS
fi
