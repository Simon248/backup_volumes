#!/bin/sh

BACKUP_PATH=$1
shift

if [ $# -eq 0 ]; then
  echo "Usage: $0 <backup_path> <volume1> [volume2 ... volumeN]"
  exit 1
fi

if [ ! -d "$BACKUP_PATH" ]; then
  echo "Le chemin de sauvegarde n'existe pas ou n'est pas un dossier."
  exit 1
fi

for VOLUME_NAME in "$@"; do
  echo "Traitement du volume: $VOLUME_NAME"

  # Identifier et stopper tous les conteneurs qui utilisent le volume
  CONTAINERS=$(docker ps -q --filter volume=$VOLUME_NAME)
  if [ ! -z "$CONTAINERS" ]; then
    echo "Arrêt des conteneurs qui utilisent le volume $VOLUME_NAME..."
    docker stop $CONTAINERS
  fi

  # Sauvegarde
  echo "Démarrage de la sauvegarde du volume $VOLUME_NAME..."
  docker run --rm -v $VOLUME_NAME:/data -v $BACKUP_PATH:/backup alpine tar czf /backup/backup_$VOLUME_NAME_$(date +"%Y%m%d_%H%M%S").tar.gz -C /data ./
  echo "Sauvegarde de $VOLUME_NAME terminée. Le backup est stocké dans $BACKUP_PATH"

  # Redémarrer les conteneurs
  if [ ! -z "$CONTAINERS" ]; then
    echo "Redémarrage des conteneurs..."
    docker start $CONTAINERS
  fi
done
