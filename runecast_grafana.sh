#!/bin/bash
##  .SYNOPSIS
##  Grafana Dashboard for Runecast - Using RestAPI to InfluxDB Script
## 
##  .DESCRIPTION
##  This Script will query the Runecast RESTful API and send the data directly to InfluxDB, which can be used to present it to Grafana. 
##  The Script and the Grafana Dashboard it is provided as it is, and bear in mind you can not open support Tickets regarding this project. It is a Community Project
##	
##  .Notes
##  NAME:  runecast_grafana.sh
##  ORIGINAL NAME: runecast_grafana.sh
##  LASTEDIT: 11/04/2021
##  VERSION: 1.0
##  KEYWORDS: runecast, InfluxDB, Grafana
   
##  .Link
##  https://jorgedelacruz.es/
##  https://jorgedelacruz.uk/

##
# Configurations
##
# Endpoint URL for InfluxDB
InfluxDBURL="http://YOURINFLUXSERVER" #Your InfluxDB Server, http://FQDN or https://FQDN if using SSL
InfluxDBPort="8086" #Default Port
InfluxDB="telegraf" #Default Database
InfluxDBUser="INFLUXUSER" #User for Database
InfluxDBPassword='INFLUXPASS' #Password for Database

# Endpoint URL for login action
runecastToken="RUNECASTOTKEN" #Your read-only Runecast token. You can quickly create one from the portal
runecastServer="RUNECASTFQDNORIP"

# Runecast Appliance Information
RunecastUrl="https://$runecastServer/rc2/api/v2/rca-instances?localOnly=false"
RunecastInfoUrl=$(curl -X GET --header "Accept:application/json" --header "Authorization:$runecastToken" "$RunecastUrl" 2>&1 -k --silent)

  RunecastUID=$(echo "$RunecastInfoUrl" | jq --raw-output ".rcaInstances[0].rcaInstanceInfo.instanceUuid")
  RunecastVersion=$(echo "$RunecastInfoUrl" | jq --raw-output ".rcaInstances[0].rcaInstanceInfo.longApplicationVersion")
  RunecastDefVersion=$(echo "$RunecastInfoUrl" | jq --raw-output ".rcaInstances[0].rcaInstanceInfo.definitionsVersion")
  RunecastDefDate=$(echo "$RunecastInfoUrl" | jq --raw-output ".rcaInstances[0].rcaInstanceInfo.definitionsCreationTs")
  RunecastVersionShort=$(echo $RunecastVersion | awk -F'.' '{print $1}')
  
  ## Un-comment the following echo for debugging  
  #echo "runecast_appliance_overview,rc2Appliance=$runecastServer,rc2ID=$RunecastUID,rc2Version=$RunecastVersion,rc2DefinitionsVersion=$RunecastDefVersion,rc2DefinitionsDate=$RunecastDefDate rc2Versionshort=$RunecastVersionShort"
  
  ##Comment the Curl while debugging
  echo "Writing runecast_appliance_overview to InfluxDB"
  curl -i -XPOST "$InfluxDBURL:$InfluxDBPort/write?precision=s&db=$InfluxDB" -u "$InfluxDBUser:$InfluxDBPassword" --data-binary "runecast_appliance_overview,rc2Appliance=$runecastServer,rc2ID=$RunecastUID,rc2Version=$RunecastVersion,rc2DefinitionsVersion=$RunecastDefVersion,rc2DefinitionsDate=$RunecastDefDate rc2Versionshort=$RunecastVersionShort"

# Runecast License Information
RunecastUrl="https://$runecastServer/rc2/api/v1/licenses"
RunecastLicenseUrl=$(curl -X GET --header "Accept:application/json" --header "Authorization:$runecastToken" "$RunecastUrl" 2>&1 -k --silent)

  RunecastLicensedHosts=$(echo "$RunecastLicenseUrl" | jq --raw-output ".licensedHosts")
  RunecastLicensedHostsCPU=$(echo "$RunecastLicenseUrl" | jq --raw-output ".licensedHostCPUs")
  RunecastLicenseID=$(echo "$RunecastLicenseUrl" | jq --raw-output ".licenses[0].id")
  RunecastLicenseName=$(echo "$RunecastLicenseUrl" | jq --raw-output ".licenses[0].name" | awk '{gsub(/ /,"\\ ");print}')
  RunecastLicenseValid=$(echo "$RunecastLicenseUrl" | jq --raw-output ".licenses[].validUntil")
  RunecastLicenseValidTS=$(date -d "$RunecastLicenseValid" +"%s")
  RunecastLicenseAllowed=$(echo "$RunecastLicenseUrl" | jq --raw-output ".licenses[].allowedCPUs")
  RunecastLicenseUsed=$(echo "$RunecastLicenseUrl" | jq --raw-output ".licenses[].usedCPUs")
  
  ## Un-comment the following echo for debugging
  #echo "runecast_license_overview,rc2Appliance=$runecastServer,rc2LicenseID=$RunecastLicenseID,rc2LicenseName=$RunecastLicenseName,rc2LicenseValid=$RunecastLicenseValidTS rc2LicensedHosts=$RunecastLicensedHosts,rc2LicensedHostsCPU=$RunecastLicensedHostsCPU,rc2LicenseAllowed=$RunecastLicenseAllowed,rc2LicenseUsed=$RunecastLicenseUsed"
  
  ##Comment the Curl while debugging
  echo "Writing runecast_license_overview to InfluxDB"
  curl -i -XPOST "$InfluxDBURL:$InfluxDBPort/write?precision=s&db=$InfluxDB" -u "$InfluxDBUser:$InfluxDBPassword" --data-binary "runecast_license_overview,rc2Appliance=$runecastServer,rc2LicenseID=$RunecastLicenseID,rc2LicenseName=$RunecastLicenseName rc2LicenseValid=$RunecastLicenseValidTS,rc2LicensedHosts=$RunecastLicensedHosts,rc2LicensedHostsCPU=$RunecastLicensedHostsCPU,rc2LicenseAllowed=$RunecastLicenseAllowed,rc2LicenseUsed=$RunecastLicenseUsed"
  
  declare -i arraylicense=0
  for row in $(echo "$RunecastLicenseUrl" | jq -r '.licenses[].licensedHosts[].vcUid'); do
    RunecastLicenseHostID=$(echo "$RunecastLicenseUrl" | jq --raw-output ".licenses[0].licensedHosts[$arraylicense].vcUid")
    RunecastLicenseHostName=$(echo "$RunecastLicenseUrl" | jq --raw-output ".licenses[0].licensedHosts[$arraylicense].name" | awk '{gsub(/ /,"\\ ");print}')
    RunecastLicenseHostCPU=$(echo "$RunecastLicenseUrl" | jq --raw-output ".licenses[0].licensedHosts[$arraylicense].hostCPUs")
    RunecastLicenseHostMOID=$(echo "$RunecastLicenseUrl" | jq --raw-output ".licenses[0].licensedHosts[$arraylicense].moid")
    
    ## Un-comment the following echo for debugging    
    #echo "runecast_license_overview,rc2Appliance=$runecastServer,rc2LicenseHostID=$RunecastLicenseHostID,rc2LicenseHostName=$RunecastLicenseHostName,rc2LicenseHostMOID=$RunecastLicenseHostMOID rc2LicenseHostCPU=$RunecastLicenseHostCPU"
  
    ##Comment the Curl while debugging
    echo "Writing runecast_license_overview to InfluxDB"
    curl -i -XPOST "$InfluxDBURL:$InfluxDBPort/write?precision=s&db=$InfluxDB" -u "$InfluxDBUser:$InfluxDBPassword" --data-binary "runecast_license_overview,rc2Appliance=$runecastServer,rc2LicenseHostID=$RunecastLicenseHostID,rc2LicenseHostName=$RunecastLicenseHostName,rc2LicenseHostMOID=$RunecastLicenseHostMOID rc2LicenseHostCPU=$RunecastLicenseHostCPU"
    
    arraylicense=$arraylicense+1
  done
  
# Runecast Results of Analysis
RunecastUrl="https://$runecastServer/rc2/api/v1/results?onlyDetectedIssues=true"
RunecastAnalysisUrl=$(curl -X GET --header "Accept:application/json" --header "Authorization:$runecastToken" "$RunecastUrl" 2>&1 -k --silent)

    RunecastResultsID=$(echo "$RunecastAnalysisUrl" | jq --raw-output ".results[0].uid")
    RunecastResultsTime=$(echo "$RunecastAnalysisUrl" | jq --raw-output ".results[0].scanStatus.timestamp")
    RunecastResultsTimeTS=$(date -d "$RunecastResultsTime" +"%s")
    RunecastResultsStatus=$(echo "$RunecastAnalysisUrl" | jq --raw-output ".results[0].scanStatus.status")
    

  declare -i arrayanalysis=0
  for row in $(echo "$RunecastAnalysisUrl" | jq -r '.results[0].issues[].id'); do
    RunecastAnalysisIssueID=$(echo "$RunecastAnalysisUrl" | jq --raw-output ".results[].issues[$arrayanalysis].id")
    RunecastAnalysisIssueDisplayID=$(echo "$RunecastAnalysisUrl" | jq --raw-output ".results[].issues[$arrayanalysis].issueDisplayId")
    RunecastAnalysisIssueAffects=$(echo "$RunecastAnalysisUrl" | jq --raw-output ".results[].issues[$arrayanalysis].affects")
    RunecastAnalysisIssueProduct=$(echo "$RunecastAnalysisUrl" | jq --raw-output ".results[].issues[$arrayanalysis].products[0].name")
    RunecastAnalysisIssueAppliesTo=$(echo "$RunecastAnalysisUrl" | jq --raw-output ".results[].issues[$arrayanalysis].appliesTo")
    RunecastAnalysisIssueSeverity=$(echo "$RunecastAnalysisUrl" | jq --raw-output ".results[].issues[$arrayanalysis].severity")
    RunecastAnalysisIssueType=$(echo "$RunecastAnalysisUrl" | jq --raw-output ".results[].issues[$arrayanalysis].type")
    RunecastAnalysisIssueTitle=$(echo "$RunecastAnalysisUrl" | jq --raw-output ".results[].issues[$arrayanalysis].title" | awk '{gsub(",", "", $0); print}' | awk '{gsub(/ /,"\\ ");print}')
    RunecastAnalysisIssueURL=$(echo "$RunecastAnalysisUrl" | jq --raw-output ".results[].issues[$arrayanalysis].url")
    RunecastAnalysisIssueObjectsCount=$(echo "$RunecastAnalysisUrl" | jq --raw-output ".results[].issues[$arrayanalysis].affectedObjectsCount")
    RunecastAnalysisIssueStatus=$(echo "$RunecastAnalysisUrl" | jq --raw-output ".results[].issues[$arrayanalysis].status")
    RunecastAnalysisIssuesAffectedJSON=$(echo "$RunecastAnalysisUrl" | jq --raw-output ".results[].issues[$arrayanalysis].affectedObjects | .")
    
    ##Un-comment the following echo for debugging
    #echo "runecast_results_analysis,rc2Appliance=$runecastServer,rc2IssueID=$RunecastAnalysisIssueID,rc2IssueDisplayID=$RunecastAnalysisIssueDisplayID,rc2IssueAffects=$RunecastAnalysisIssueAffects,rc2IssueProduct-=$RunecastAnalysisIssueProduct,rc2IssueApplietsTo=$RunecastAnalysisIssueAppliesTo,rc2IssueSeverity=$RunecastAnalysisIssueSeverity,rc2IssueType=$RunecastAnalysisIssueType,rc2IssueTitle=$RunecastAnalysisIssueTitle,rc2IssueURL=$RunecastAnalysisIssueURL,rc2IssueStatus=$RunecastAnalysisIssueStatus rc2IssueObjectsCount=$RunecastAnalysisIssueObjectsCount $RunecastResultsTimeTS"

    ##Comment the Curl while debugging
    echo "Writing runecast_results_analysis to InfluxDB"
    curl -i -XPOST "$InfluxDBURL:$InfluxDBPort/write?precision=s&db=$InfluxDB" -u "$InfluxDBUser:$InfluxDBPassword" --data-binary "runecast_results_analysis,rc2Appliance=$runecastServer,rc2IssueID=$RunecastAnalysisIssueID,rc2IssueDisplayID=$RunecastAnalysisIssueDisplayID,rc2IssueAffects=$RunecastAnalysisIssueAffects,rc2IssueProduct=$RunecastAnalysisIssueProduct,rc2IssueApplietsTo=$RunecastAnalysisIssueAppliesTo,rc2IssueSeverity=$RunecastAnalysisIssueSeverity,rc2IssueType=$RunecastAnalysisIssueType,rc2IssueTitle=$RunecastAnalysisIssueTitle,rc2IssueURL=$RunecastAnalysisIssueURL,rc2IssueStatus=$RunecastAnalysisIssueStatus rc2IssueObjectsCount=$RunecastAnalysisIssueObjectsCount $RunecastResultsTimeTS"
    
    declare -i arrayobjects=0
    for row in $(echo "$RunecastAnalysisIssuesAffectedJSON" | jq -r '.[].vcUid'); do
        RunecastAnalysisIssueObjectID=$(echo "$RunecastAnalysisIssuesAffectedJSON" | jq --raw-output ".[$arrayobjects].vcUid")    
        RunecastAnalysisIssueObjectName=$(echo "$RunecastAnalysisIssuesAffectedJSON" | jq --raw-output ".[$arrayobjects].name" | awk '{gsub(/ /,"\\ ");print}')  
        RunecastAnalysisIssueObjectType=$(echo "$RunecastAnalysisIssuesAffectedJSON" | jq --raw-output ".[$arrayobjects].type")
        RunecastAnalysisIssueObjectMOID=$(echo "$RunecastAnalysisIssuesAffectedJSON" | jq --raw-output ".[$arrayobjects].moid")
        RunecastAnalysisIssueObjectDescription=$(echo "$RunecastAnalysisIssuesAffectedJSON" | jq --raw-output ".[$arrayobjects].resultValues[0].description" | awk '{gsub(",", "", $0); print}' | awk '{gsub(/ /,"\\ ");print}' ) 
        RunecastAnalysisIssueObjectValue=$(echo "$RunecastAnalysisIssuesAffectedJSON" | jq --raw-output ".[$arrayobjects].resultValues[0].value" | awk '{gsub(",", "", $0); print}' | awk '{gsub("=", "-", $0); print}' | awk '{gsub(/ /,"\\ ");print}')
        [[ ! -z "$RunecastAnalysisIssueObjectValue" ]] || RunecastAnalysisIssueObjectValue="None"
        
        ##Un-comment the following echo for debugging    
        #echo "runecast_results_analysis,rc2Appliance=$runecastServer,rc2IssueID=$RunecastAnalysisIssueID,rc2IssueDisplayID=$RunecastAnalysisIssueDisplayID,rc2IssueObjectID=$RunecastAnalysisIssueObjectID,rc2IssueObjectName=$RunecastAnalysisIssueObjectName,rc2IssueObjectType=$RunecastAnalysisIssueObjectType,rc2IssueObjectMOID=$RunecastAnalysisIssueObjectMOID,rc2IssueObjectDesc=$RunecastAnalysisIssueObjectDescription,rc2IssueObjectValue=$RunecastAnalysisIssueObjectValue rc2IssueObjectsCount=$RunecastAnalysisIssueObjectsCount $RunecastResultsTimeTS"
        
        ##Comment the Curl while debugging
        echo "Writing runecast_results_analysis to InfluxDB"
        curl -i -XPOST "$InfluxDBURL:$InfluxDBPort/write?precision=s&db=$InfluxDB" -u "$InfluxDBUser:$InfluxDBPassword" --data-binary "runecast_results_analysis,rc2Appliance=$runecastServer,rc2IssueID=$RunecastAnalysisIssueID,rc2IssueDisplayID=$RunecastAnalysisIssueDisplayID,rc2IssueObjectID=$RunecastAnalysisIssueObjectID,rc2IssueObjectName=$RunecastAnalysisIssueObjectName,rc2IssueObjectType=$RunecastAnalysisIssueObjectType,rc2IssueObjectMOID=$RunecastAnalysisIssueObjectMOID,rc2IssueObjectDesc=$RunecastAnalysisIssueObjectDescription,rc2IssueObjectValue=$RunecastAnalysisIssueObjectValue rc2IssueObjectsCount=$RunecastAnalysisIssueObjectsCount $RunecastResultsTimeTS"
        
        arrayobjects=$arrayobjects+1
    done
    
    arrayanalysis=$arrayanalysis+1
  done