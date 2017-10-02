# /*****************************************************************************
# * Copyright (c) 2016, Palo Alto Networks. All rights reserved.              *
# *                                                                           *
# * This Software is the property of Palo Alto Networks. The Software and all *
# * accompanying documentation are copyrighted.                               *
# *****************************************************************************/
#
# Copyright 2016 Palo Alto Networks
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


import time
import shlex
import subprocess
import os
import logging
import urllib2
import sys
import ssl
import xml.etree.ElementTree as et
import threading

LOG_FILENAME = 'azure.log'
logging.basicConfig(filename=LOG_FILENAME,level=logging.INFO, filemode='w',format='[%(levelname)s] (%(threadName)-10s) %(message)s',)
logger = logging.getLogger(__name__)
logger.setLevel(logging.INFO)

#What is management IP address of eth0?
MgmtIp = sys.argv[1]

#The api key is pre-generated for fwadmin/Paloalto123
# CHANGE THIS FOR YOUR OWN USAGE
api_key = "LUFRPT1DQlBRa3FXWmFOUkZQUklCZjhlZDFlbDM1Zlk9eDNmVHBTS2l2cVV3Rm94eXZvMDAxSjVGelFXeFBvT1V1Z0ttR2I0QVpPWT0="

#Need this to by pass invalid certificate issue. Should try to fix this
gcontext = ssl.SSLContext(ssl.PROTOCOL_TLSv1_2)


def main():

    t1 = threading.Thread(name='config_fw',target=config_fw)
    t1.start()

def config_fw():
    global api_key
    global MgmtIp

    #This means firewall already configured..so exit script.
    if os.path.exists("./firewall_configured") == True:
        logger.info("[INFO]: FW already configured. auf wiedersehen!")
        return 'true'

    err = 'no'
    while (True):
        err = check_auto_commit_status()
        if err == 'yes':
            break
        else:
          time.sleep(10)
          continue

    while (True):
        err = check_fw_up()
        if err == 'yes':
            break
        else:
            time.sleep(10)
            continue

def check_fw_up():
    global gcontext
    global MgmtIp
    global api_key
    cmd = "https://"+MgmtIp+"/api/?type=op&cmd=<show><chassis-ready></chassis-ready></show>&key="+api_key
    #Send command to fw and see if it times out or we get a response
    logger.info('[INFO]: Sending command: %s', cmd)
    try:
        response = urllib2.urlopen(cmd, context=gcontext, timeout=5).read()
        #response = urllib2.urlopen(cmd, timeout=5).read()
    except Exception as e:
        logger.info("[INFO]: No response from FW. So maybe not up! {}".format(e))
        return 'no'
    else:
        logger.info("[INFO]: FW is up!!")

    logger.info("[RESPONSE]: {}".format(response))
    resp_header = et.fromstring(response)

    if resp_header.tag != 'response':
        logger.info("[ERROR]: didn't get a valid response from firewall...maybe a timeout")
        return 'cmd_error'

    if resp_header.attrib['status'] == 'error':
        logger.info("[ERROR]: Got an error for the command")
        return 'cmd_error'

    if resp_header.attrib['status'] == 'success':
    #The fw responded with a successful command execution. So is it ready?
        for element in resp_header:
            if element.text.rstrip() == 'yes':
                logger.info("[INFO]: FW is ready for configure")
                return 'yes'
            else:
                return 'almost'

def check_auto_commit_status():
    global gcontext
    global MgmtIp
    global api_key

    job_id = '1' #auto commit job id is always 1
    cmd = "https://"+MgmtIp+"/api/?type=op&cmd=<show><jobs><id>"+job_id+"</id></jobs></show>&key="+api_key
    #Send command to fw and see if it times out or we get a response
    logger.info('[INFO]: Sending command: %s', cmd)
    try:
        response = urllib2.urlopen(cmd, context=gcontext, timeout=5).read()
        #response = urllib2.urlopen(cmd,  timeout=5).read()
    except Exception as e:
        logger.info("[INFO]: No response from FW. So maybe not up! {}".format(e))
        return 'no'
    else:
        logger.info("[INFO]: FW is up!!")

    logger.info("[RESPONSE]: {}".format(response))
    resp_header = et.fromstring(response)

    if resp_header.tag != 'response':
        logger.info("[ERROR]: didn't get a valid response from firewall...maybe a timeout")
        return 'cmd_error'

    if resp_header.attrib['status'] == 'error':
        logger.info("[ERROR]: Got an error for the command")
        for element1 in resp_header:
            for element2 in element1:
                if element2.text == "job 1 not found":
                    logger.info("[INFO]: Job 1 not found...so try again")
                    return 'almost'
                elif "Invalid credentials" in element2.text:
                    logger.info("[INFO]:Invalid credentials...so try again")
                    return 'almost'
                else:
                    logger.info("[ERROR]: Some other error when checking auto commit status")
                    return 'cmd_error'

    if resp_header.attrib['status'] == 'success':
    #The fw responded with a successful command execution. So is it ready?
        for element1 in resp_header:
            for element2 in element1:
                for element3 in element2:
                    if element3.tag == 'status':
                        if element3.text == 'FIN':
                            logger.info("[INFO]: FW is ready for configure")
                            return 'yes'
                        else:
                            return 'almost'


def check_job_status(job_id):

    global gcontext
    global MgmtIp
    global api_key

    cmd = "https://"+MgmtIp+"/api/?type=op&cmd=<show><jobs><id>"+job_id+"</id></jobs></show>&key="+api_key
    logger.info('[INFO]: Sending command: %s', cmd)
    try:
        response = urllib2.urlopen(cmd, context=gcontext, timeout=5).read()
        #response = urllib2.urlopen(cmd,  timeout=5).read()
    except Exception as e:
        logger.info("[ERROR]: ERROR...fw should be up!! {}".format(e))
        return 'false'

    logger.info("[RESPONSE]: {}".format(response))
    resp_header = et.fromstring(response)

    if resp_header.tag != 'response':
        logger.info("[ERROR]: didn't get a valid response from firewall...maybe a timeout")
        return 'false'

    if resp_header.attrib['status'] == 'error':
        logger.info("[ERROR]: Got an error for the command")
        for element1 in resp_header:
            for element2 in element1:
                if element2.text == "job "+job_id+" not found":
                    logger.info("[ERROR]: Job "+job_id+" not found...so try again")
                    return 'false'
                elif "Invalid credentials" in element2.text:
                    logger.info("[ERROR]:Invalid credentials...")
                    return 'false'
                else:
                    logger.info("[ERROR]: Some other error when checking auto commit status")
                    return 'false'

    if resp_header.attrib['status'] == 'success':
        for element1 in resp_header:
            for element2 in element1:
                for element3 in element2:
                    if element3.tag == 'status':
                        if element3.text == 'FIN':
                            logger.info("[INFO]: Job "+job_id+" done")
                            return 'true'
                        else:
                            return 'pending'

if __name__ == "__main__":
    main()
