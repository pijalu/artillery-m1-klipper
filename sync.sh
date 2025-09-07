#/bin/sh
PRINTERIP=$1
if [[ "$PRINTERIP" == "" ]]
then
    echo "$0 printer-ip"
    exit 42
fi
echo "Retrieving running configurations from ${PRINTERIP}..."
rsync -avxL --stats linaro@${PRINTERIP}:/home/mks/printer_data/config/ config
echo "Retrieving factory configuration from ${PRINTERIP}..."
rsync -avxL --stats linaro@${PRINTERIP}:/home/mks/ws/doc/ factory/
