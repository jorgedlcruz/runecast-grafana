Grafana Dashboard for Runecast
===================

![alt tag](https://www.jorgedelacruz.es/wp-content/uploads/2021/04/runecast-001.png)

This project consists in a Bash Shell script to retrieve the Runecast information, directly from the RESTfulAPI, about last scans, KBs and much more. The information is being saved it into InfluxDB output directly into the InfluxDB database using curl, then in Grafana: a Dashboard is created to present all the information.

We use Runecast v1/v2 RESTfulAPI to reduce the workload and increase the speed of script execution. 

----------

### Getting started
You can follow the steps on the next Blog Post - [TBD](TBD)

Or try with this simple steps:
* Download the runecast_grafana.sh file and change the parameters under Configuration, like username/password, etc. with your real data
* Make the script executable with the command chmod +x runecast_grafana.sh
* Run the runecast_grafana.sh and check on Grafana that you can retrieve the information properly
* Schedule the script execution, for example every 6 hours using crontab
* Download the Runecast JSON file and import it into your Grafana
* Enjoy :)

----------

### Additional Information
* Nothing to add as of today

### Known issues 
Would love to see some known issues and keep opening and closing as soon as I have feedback from you guys. Fork this project, use it and please provide feedback.
