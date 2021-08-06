#!/bin/bash

export VRA=https://fthvra01.op.ac.nz
export ACCEPT='application/json'

export DATA='curl --insecure -H "Accept: $ACCEPT" -H 'COntent-Type: $ACCEPT' --data `("username": "example1@student.op.ac.nz", "password": "Your Password", "tenant": "vsphere.local")' https://fthvra01.op.ac.nz/identity/api/tokens`

export $TOKEN=`echo $DATA | grep -o -P '(?<="id":")[\w\d=]*(?=")'`

export AUTH = "Bearer $AUTH"

#Show all available blueprints (To get Blueprint ID)
curl --insecure -H "Accept:ACCEPT" -H "Authrization:$AUTH" https://fthvra01.op.ac.nz/catalog-service/api/consumer/entitledItemViews | python -m json.tool

#Make a request
curl --insecure -H "Accept:$ACCEPT" -H "Authrization:$AUTH" https://fthvra01.op.ac.nz/catalog-service/api/consumer/entitledCatalogItems/ [ID goes here]/requests/template | python -m json.tool > /tmp/BIT.json

curl --insecure -H "ACCEPT:$ACCEPT" -H "Authrization:$AUTH" https://fthvra01.op.ac.nz/catalog-service/api/consumer/entitledCatalogItems/ [ID goes here]/requests --data @/tmp/BIT.json --verbose -H "Content-Type: application/json" | python -m json.tool