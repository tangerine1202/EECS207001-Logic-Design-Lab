#!/usr/bin/python3
import os
from datetime import datetime as dt

# Configuration
CAD_IP = '140.114.75.200'
CAD_IC = 'ic23'
TIME_SEQ = dt.now().strftime('%m%d%H%M%S')

# User
user = ''  # Your username here, ex: u108062000
lab = ''  # The prefix of the directory created on CAD, recommend using lab#
ds = ''  # Design file
tb = ''  # Testbench file

# Input
while user == '':
	user = input('user: ')
	user.strip()
while lab == '':
	lab = input('lab name: ')
	lab.strip()
while ds == '':
	ds = input('design: ')
	ds.strip()
	if not ds.endswith('.v'):
		ds += '.v'
while tb == '' or tb == 'n' or tb == 'no':
	tb = input('testbench [{}](yes/<path>): '.format(ds[:-2]+'_t.v'))
	tb.strip()
	if tb == 'y' or tb == 'yes':
		tb = ds[:-2] + '_t.v'
	elif (tb != '') and (not tb.endswith('.v')):
		tb += '.v'

print("""
[*] Design:    {}
[*] Testbench: {}
""".format(ds, tb))

# Remote Command
user_at_host = '{}@{}'.format(user, CAD_IP)
dir_name = './autotest/{}/{}_{}/'.format(lab, ds[:-2], TIME_SEQ)
remote_cmd = ''
# Setting Cadence License(in order to use ncverilog)
remote_cmd += 'source /usr/cad/cadence/setup.csh;'
remote_cmd += 'mkdir -p {};'.format(dir_name)
remote_cmd += 'mv {} {} {};'.format(ds, tb, dir_name)
remote_cmd += 'cd {};'.format(dir_name)
remote_cmd += 'ncverilog {} {};'.format(ds, tb)

remote_cmd = 'ssh -tt {} \\"{}\\"'.format(CAD_IC, remote_cmd)

# Connect
print('[+] Copying file to CAD...')
os.system('scp {} {} {}:~/'.format(ds, tb, user_at_host))

print('[+] Seletct remote host & Run ncverilog...')
os.system('ssh -tt {} "{}"'.format(user_at_host, remote_cmd))

print('[+] Test done.')

