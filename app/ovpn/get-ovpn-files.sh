#!/bin/bash

. /app/date.sh --source-only

function download_files {
  # the current ovpn zip file is more than two hours old.
  echo "$(adddate) INFO: Downloading new OVPN files."

  #Remove current zip
  rm -rf ${OVPN_CONFIG_DIR}/ovpn.zip

  #Create directory if no volume is done
  mkdir -p ${OVPN_CONFIG_DIR}

  #First remove files if exists
  rm -rf ${OVPN_CONFIG_DIR}/ovpn*

  #Curl download ovpn files from NordVPN
  curl -s -o ${OVPN_CONFIG_DIR}/ovpn.zip ${OVPN_FILES}

  #Unzip files
  unzip -q ${OVPN_CONFIG_DIR}/ovpn.zip -d ${OVPN_CONFIG_DIR}

  #Print out logging
  if [ $? -eq 0 ]; then
    echo "$(adddate) INFO: OVPN files successfully unzipped to $OVPN_CONFIG_DIR"

    for file in $(ls ${OVPN_CONFIG_DIR}/ovpn_tcp/*.ovpn); do
      sed -i '/auth-user-pass/d' $file
    done

  else
    echo "$(adddate) ERROR: OVPN files unzipped failed!"
  fi
}

# check if the file exists
if [ -f ${OVPN_CONFIG_DIR}/ovpn.zip ]; then
  #the file exists continue checking if its older than two hours.
  if test `find ${OVPN_CONFIG_DIR}/ovpn.zip -mmin +${REFRESH_TIME}`; then
    download_files
  else
    echo "$(adddate) INFO: Skipping downloading OVPN files - as they are not older than ${REFRESH_TIME} minute(s)."
  fi
else
  #the files don't exists continue to download and extract them.
  download_files
fi
