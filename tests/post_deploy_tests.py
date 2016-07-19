import sys
import unittest
import urllib2

import os
import urllib2
import unittest
import subprocess
import shlex

import subprocess

import socket;
import boto3
import json
#server_ip = '54.186.144.194'
#server_url = 'http:/%s' %server_ip
#
   
class TestDeployedServer(unittest.TestCase):

    def setUp(self):
        ec2 = boto3.client('ec2')  
        filters = [{  
            'Name': 'instance-id',
            'Values': [self.instance_id]
        }]
 
        reservations = ec2.describe_instances(Filters=filters)  

        self.sec_groups = [group['GroupName'] for group in reservations['Reservations'][0]['Instances'][0]['SecurityGroups']]
        #self.sec_groups = reservations['Reservations'][0]['Instances'][0]['SecurityGroups']

        self.server_url = 'http://' + reservations['Reservations'][0]['Instances'][0]['PublicDnsName']
        print self.sec_groups
   
    def test_correct_security_group(self):
        sec_group = 'MiniProjectSecGroup'
        correct_groups = sec_group in self.sec_groups
        self.assertTrue(correct_groups)

    def test_server_is_reachable(self):
        code = urllib2.urlopen(self.server_url).getcode()

        is_200 = (code is 200)

        self.assertTrue(is_200)
        

    def test_webpage_is_correct(self):
        message = 'automation for the people'
        html = urllib2.urlopen(self.server_url).read()
        is_correct = message in html.lower()

if __name__ == '__main__':



   
    TestDeployedServer.instance_id = sys.argv.pop()
    unittest.main()



