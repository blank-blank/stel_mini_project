import os
import urllib2
import unittest
import subprocess
import shlex

import subprocess

import socket;

def run_piped_command(cmd):

    '''
    Use popen to execute cmd
    return a tuple of stdout, stderr data
    '''

    args= shlex.split(cmd)#['echo', '"to stdout"']

    proc = subprocess.Popen(args, 
                        stdout=subprocess.PIPE,stderr=subprocess.PIPE,
                        )
    return proc.communicate()

    
 
class TestNginxLocal(unittest.TestCase):

    def test_nginx_is_intsalled(self):

        package = 'nginx'
        check_install_command = 'yum list installed %s' %package

        stdout, stderr = run_piped_command(check_install_command)   
        print stderr 
        is_installed = (stderr is '')

        self.assertTrue(is_installed)

    def test_nginx_is_running(self):

        is_running_cmd = 'service nginx status'

        stdout, stderr = run_piped_command(is_running_cmd)
        is_running = 'is running' in stdout 
        self.assertTrue(is_running)

    def test_nginx_port_is_listening(self):
        nginx_port = 80

        sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)

        result = sock.connect_ex(('127.0.0.1',nginx_port))

        port_is_open = (result is 0)

        self.assertTrue(port_is_open)

    def test_can_curl_localhost(self):
        is_200 = urllib2.urlopen('http://localhost').getcode() is 200
        self.assertTrue(is_200)

    def test_index_file_exists(self):
        index_filepath = '/usr/share/nginx/html/index.html'
        file_exists = os.path.isfile(index_filepath) 
        self.assertTrue(file_exists)

if __name__ == '__main__':

    unittest.main()