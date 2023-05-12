#!/bin/bash

###################################################################
#Script Name: webdav.sh
#Description: Monta un servidor webdav con rclone
#Args: N/A
#Creation/Update: 20211217/20211217
#Author: www.sherblog.pro                                                
#Email: sherlockes@gmail.com                                           
###################################################################

sleep 30
rclone serve webdav Sherlockes78_UN3_en: --addr 192.168.10.202:5005 --read-only
#rclone serve webdav Sherlockes78_UN_en: --addr 192.168.10.202:5005 --read-only
