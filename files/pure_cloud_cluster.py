#!/usr/bin/env python2
import socket
try:
    import psycopg2
except:
    psycopg2 = None

def printfacts(facts, prec=""):
    if type(facts) == dict:
        for k in facts:
            newprec=k
            if prec:
               newprec="{0}_{1}".format(prec,newprec)
            printfacts(facts[k], newprec)
    elif type(facts) == list:
        print("{0}={1}".format(prec,",".join(facts)))
    else:
        print("{0}={1}".format(prec,str(facts)))

def ssh_public_key(file):
    try:
        f=open(file)
    except:
        return {}
    for l in f:
        l=l.strip()
        l=l.split('#')[0]
        try:
            type, key, comment = l.split(' ')[:3]
            return {'type': type, 'key': key, 'comment': comment}
        except:
            pass           
    return {}

def check_connectivity(host, port):
    try:
        s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        s.settimeout(0.1)
        s.connect((host, port))
    except:
        return False
    s.close()
    return True

def ip_to_int(ip):
    if type(ip) is int:
      return ip
    if type(ip) is str:
      ip_ar = ip.split(".")
      if len(ip_ar) != 4:
        raise Exception("Invalid IP: {0}. We need 4 numbers in an IP".format(ip))
      ip=0
      for i in ip_ar:
        try:
          i=int(i)
        except:
          raise Exception("IP part {0} must be numeric".format(i))
        if i<0 or i>255:
          raise Exception("IP part {0} must be from 0-255".format(i))
        ip=ip*256+i
      return ip
    raise Exception("{0} has an invalid type for an IP.".format(ip.__repr__()))

def int_to_ip(i):
    if type(i) is str:
      return i
    try:
      i = int(i)
    except:
      raise Exception("{0} is not an integer.".format(i.__repr__()))
    ip = ""
    for x in range(4):
      ip += "." + str(int(i/2**(8*(3-x)) % 256))
    return ip[1:]

def cidr_to_netmask(cidr):
    if type(cidr) is str:
      if '/' in cidr:
        cidr=cidr.split('/')[1]
    try:
      cidr=int(cidr)
    except:
      raise Exception("invalid numeric expression for network cidr {}".format(cidr))
    return (2**cidr-1) * 2** (32-cidr)

def network(ip, netmask):
    return ip_to_int(ip) & ip_to_int(netmask)

def gateway(ip, netmask):
    return (ip_to_int(ip) & ip_to_int(netmask))+1

def broadcast(ip, netmask):
    netmask=ip_to_int(netmask)
    #eerst network adress
    t = ip_to_int(ip) & ip_to_int(netmask)
    #daarna inverse van netmask erbij optellen
    t += ip_to_int(netmask) ^ (2 ** 32 - 1)
    return t

def process_config_files(list_of_config_files):
    settings={}
    for f in list_of_config_files:
        try:
            with open(f) as configfile:
                for l in configfile:
                    #take out comment
                    l=l.split('#')[0]
                    if '=' in l:
                        k,v = l.split('=',1)
                        k=k.strip()
                        v=v.strip()
                        if len(v) > 0 and len(k) > 0:
                            settings[k]=v
        except:
            pass
    return settings

if __name__ == "__main__":
    import sys
    import json
    import os

    settings = process_config_files([ '/etc/repmgr.conf', '/etc/facter/facts.d/pure_cloud_cluster.ini' ])

    try:
        defaultprimarynetwork = settings['primarynetwork']
    except:
        defaultprimarynetwork = None

    defaultdns = None
    for setting in ['dnsname', 'cluster']:
        try:
            defaultdns = settings[setting]
            break
        except:
            pass

    import argparse
    parser = argparse.ArgumentParser(description='Read cluster setup from DNS.')
    parser.add_argument('-n', '--name', default=defaultdns, help='DNS name to read (Without domain, domain name from machine is used).')
    parser.add_argument('-l', '--primarynetwork', default=defaultprimarynetwork, help='Network segment of primary site. This helps to detect initial master.')
    parser.add_argument('-p', '--port', default=5432, help='Port where postgres is running on.')
    args = parser.parse_args()

    if not args.name:
        print('You should set the DNS of this cluster\n- with --name, or\n- in inifile /etc/facter/facts.d/pure_cloud_cluster.ini or\n- in config file /etc/repmgr.conf')
        sys.exit()
    if '/' not in args.primarynetwork:
        print('Invalid --primarynetwork. \nShould be: IP/CIDR (e.a. 1.2.3.4/16). \nSet it in /etc/facter/facts.d/pure_cloud_cluster.ini or with --primarynetwork.')
        sys.exit()

    try:
        repmgr_cluster_name = settings['cluster']
    except:
        repmgr_cluster_name = args.name.split('.')[0]

    if not '.' in args.name:
        try:
            domain_name = socket.getfqdn().split('.',1)[1]
            dns = "{0}.{1}".format(args.name, domain_name)
        except:
            dns = args.name
    else:
        dns = args.name

    nw, cidr = args.primarynetwork.split('/')
    nw_start = gateway(nw, cidr_to_netmask(cidr)) - 1
    nw_end = broadcast(nw, cidr_to_netmask(cidr)) + 1
    #print(nw, cidr, int_to_ip(nw_start), int_to_ip(nw_end))

    try:
        IPs = socket.gethostbyname_ex(dns)
        if not IPs:
            raise Exception
    except:
        print('no IPs found by DNS {0}.'.format(dns))
        sys.exit()

    #All IP addresses that are in the primary network
    #print(ip_to_int(IPs[2][0]), nw_start, nw_end)
    primary_site = set()
    secondary_site = set()
    for IP in IPs[2]:
        IP_int = ip_to_int(IP)
        if IP_int >= nw_start and IP_int <= nw_end:
            primary_site.add(IP_int)
        else:
            secondary_site.add(IP_int)

    primary_site = sorted(primary_site)
    initialmaster=int_to_ip(primary_site[0])
    primary_site = [ int_to_ip(IP) for IP in primary_site ]
    secondary_site = [ int_to_ip(IP) for IP in sorted(secondary_site) ]
    all_sites = primary_site + secondary_site
    available_hosts = [ host for host in all_sites if check_connectivity(host, args.port) ]
    try:
        my_id = settings['node']
    except:
        all_sites = primary_site + secondary_site
        my_ip = socket.gethostbyname(socket.gethostname())
        my_id = all_sites.index(my_ip) + 1

    try:
        cn=psycopg2.connect(database='repmgr', host=socket.gethostname(), user='repmgr')
        cur=cn.cursor()
        cur.execute('select pg_is_in_recovery()')
        if cur.next()[0]:
            replication_role = 'standby'
        else:
            replication_role = 'master'
    except Exception as e:
        replication_role = None 

    facts = dict()
    facts['pure_cloud_cluster']           = repmgr_cluster_name
    facts['pure_cloud_clusterdns']        = dns
    facts['pure_cloud_nodes']             = (primary_site + secondary_site)
    facts['pure_cloud_available_hosts']   = available_hosts
    facts['pure_cloud_nodeid']            = my_id
    facts['pure_cloud_primarysite']       = primary_site
    facts['pure_cloud_secondarysite']     = secondary_site
    facts['pure_postgres_ssh_public_key'] = ssh_public_key('/home/postgres/.ssh/id_rsa.pub')
    if replication_role:
        facts['pure_replication_role']        = replication_role

#    print(json.dumps(facts))
    printfacts(facts)
