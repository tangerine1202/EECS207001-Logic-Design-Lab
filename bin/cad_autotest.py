#!/usr/bin/python3
import os
from datetime import datetime as dt

# Configuration
CAD_IP = '140.114.75.200'
CAD_IC = 'ic23'
TIME_SEQ = dt.now().strftime('%m%d%H%M%S')

# User
user = 'u108062308'  # Your username here, ex: u108062000
lab = 'lab4'  # The prefix of the directory created on CAD, recommend using lab#
ds = '../lab4/Mealy_Sequence_Detector/Lab4_TeamX_Mealy_Sequence_Detector.v'  # Design file
tb = '../lab4/Mealy_Sequence_Detector/Lab4_TeamX_Mealy_Sequence_Detector_t.v'  # Testbench file

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
	tb = input(f"testbench [{ds[:-2]+'_t.v'}](yes/<path>):")
	tb.strip()
	if tb == 'y' or tb == 'yes':
		tb = ds[:-2] + '_t.v'
	elif (tb != '') and (not tb.endswith('.v')):
		tb += '.v'

print(f"""
[*] Design:    {ds}
[*] Testbench: {tb}
""")

# Remote Command
user_at_host = f'{user}@{CAD_IP}'
dir_name = f'./autotest/{lab}/{ds[:-2]}{TIME_SEQ}/'
remote_cmd = ''
# Setting Cadence License(in order to use ncverilog)
remote_cmd += 'source /usr/cad/cadence/setup.csh;'
remote_cmd += f'mkdir -p {dir_name};'
remote_cmd += f'mv {ds} {tb} {dir_name};'
remote_cmd += f'cd {dir_name};'
remote_cmd += f'ncverilog {ds} {tb};'

remote_cmd = f'ssh -tt {CAD_IC} \\"{remote_cmd}\\"'

# Connect
print('[+] Copying file to CAD...')
os.system(f'scp {ds} {tb} {user_at_host}:~/')

print('[+] Seletct remote host & Run ncverilog...')
os.system(f'ssh -tt {user_at_host} "{remote_cmd}"')

print('[+] Test done.')

