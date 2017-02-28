#!/usr/bin/env python2
import socket
import datetime
import traceback
 
try:
    import psycopg2
except:
    psycopg2 = None

lag_query = '''SELECT ts, 
CASE WHEN (receive_location IS NULL OR receive_location < replay_location)
  THEN replay_location
  ELSE receive_location
  END AS receive_location,
replay_location,
replay_timestamp,
COALESCE(receive_location, '0/0') >= replay_location AS receiving_streamed_wal
FROM (SELECT CURRENT_TIMESTAMP AS ts,
  pg_catalog.pg_last_xlog_receive_location() AS receive_location,
  pg_catalog.pg_last_xlog_replay_location()  AS replay_location,
  pg_catalog.pg_last_xact_replay_timestamp() AS replay_timestamp
  ) q'''

def print_exception(e):
    try:
        traceback.print_exc()
    except:
        print('Could not handle exception {}'.format(str(e)))

def lsn_to_xlogrecptr(lsn):
    xlogid, xrecoff = lsn.split('/')
    xlogid  = int(xlogid, 16)
    xrecoff = int(xrecoff, 16)
    return xlogid * 16 * 1024 * 1024 * 255 + xrecoff

class pg_cluster_logger_exception(SystemError):
    pass

class pg_server():
    def __init__(self, ip, port=5432, debug=False, conn_timeout=3):
        self.ip      = ip
        self.port    = port
        self.cn      = None
        self.debug   = debug
        self.timeout = conn_timeout

    def __del__(self):
        try:
            self.cn.close()
        except AttributeError:
            pass

    def connect(self):
        if self.cn:
            if self.replication_role() != 'unknown':
                return True            
        try:
            self.cn  = psycopg2.connect(database="repmgr", user="repmgr", host=self.ip, port=self.port, connect_timeout=self.timeout)
            self.cn.autocommit = True
            return True
        except psycopg2.OperationalError as e:
            if self.debug:
                print_exception(e)
            self.cn  = None
            return False

    def run_sql(self, sql, params=None):
        if not self.cn:
            self.connect()
        try:
            cur=self.cn.cursor()
            cur.execute(sql, params)
            columns = [i[0] for i in cur.description]
            ret = [dict(zip(columns, row)) for row in cur]
            cur.close()
            return ret
        except psycopg2.DatabaseError as e:
            if self.debug:
                print_exception(e)
                print("On query: {0}\nWith params: {1}".format(sql, repr(params)))
            return None
        except AttributeError:
            return None
        except psycopg2.InterfaceError:
            return None

    def replication_role(self):
        is_in_recovery = self.run_sql('SELECT pg_is_in_recovery() as is_in_recovery')
        if not is_in_recovery:
            return 'unknown'
        elif is_in_recovery[0]['is_in_recovery']:
            return 'standby'
        else:
            return 'master'

    def master(self):
        if self.replication_role() == 'master':
            return True
        return False

    def standby(self):
        if self.replication_role() == 'standby':
            return True
        return False

    def standby_lag_info(self):
        if not self.standby():
            return None
        lag_info = self.run_sql(lag_query)
        if not lag_info:
             return None
        return lag_info[0]

    def master_lag_info(self):
        if not self.master():
            return None
        lag_info = self.run_sql('SELECT current_timestamp as ts, pg_catalog.pg_current_xlog_location() as xlog_location')
        if not lag_info:
             return False
        return lag_info[0]

    def lag_info(self, master):
        try:
            master_repl_info = master.master_lag_info()
            masterts, masterxlogrecptr = master_repl_info['ts'], lsn_to_xlogrecptr(master_repl_info['xlog_location'])
        except:
            raise pg_cluster_logger_exception('Cannot detect lag without master lag info')
        my_repl_info = self.standby_lag_info()
        if not my_repl_info:
            return None

        myts         = my_repl_info['replay_timestamp']
        myxlogrecptr = lsn_to_xlogrecptr(my_repl_info['receive_location'])
        myxlogrepptr = lsn_to_xlogrecptr(my_repl_info['replay_location'])

        lsn_rec_lag = masterxlogrecptr - myxlogrecptr
        lsn_rep_lag = masterxlogrecptr - myxlogrepptr
        if lsn_rep_lag > 0:
            ts_lag      = round((masterts - myts).total_seconds())
        else:
            ts_lag      = 0

        return (ts_lag, lsn_rep_lag, lsn_rec_lag)

    def config_parameter(self, key):
        result = self.run_sql('select setting from pg_settings where name = %s', (key,))
        if result:
            return result[0]['setting']
        return None

    def num_connections(self):
        result = self.run_sql('SELECT sum(numbackends) as connections FROM pg_stat_database')
        if result:
            return result[0]['connections']
        return None

    def accesslevel(self):
        if self.num_connections():
            ret = 3
        elif self.check_connectivity():
            ret = 2
        elif self.check_connectivity(port=22):
            ret = 1
        else:
            ret = 0
        return ret

    def check_connectivity(self, port=None):
        if not port:
            port=self.port
        try:
            s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            s.settimeout(0.1)
            s.connect((self.ip, port))
        except:
            return False
        s.close()
        return True

class pg_cluster():
    def __init__(self, dns, postgresport=5432, local_node_name=socket.gethostname(), logfile='/etc/pgpure/cluster_logger/cluster_logger.ini', debug=False, conn_timeout=3):
        self.dns           = dns
        self.postgresport  = postgresport
        self.nodes         = {}
        self.exceptions    = []
        self.local_node_ip = socket.gethostbyname(local_node_name)
        self.last_state    = None
        self.master        = None
        self.logfile       = logfile
        self.logfile_obj   = None
        self.debug         = debug
        self.conn_timeout  = conn_timeout

    def update_nodelist(self):
        nodes = {}
        master = None
        for ip in self.ipsfromdns():
            try:
                server = self.nodes[ip]
            except:
                server = pg_server(ip=ip, port=self.postgresport, debug=self.debug, conn_timeout=self.conn_timeout)
            nodes[ip] = server
            if server.master():
                if master:
                    self.exceptions.append('Multiple masters in this cluster...')
                else:
                    master = server
        old_nodes = set(self.nodes.keys()) - set(nodes.keys())

        for node in old_nodes:
            server = self.nodes[node]
            server.__del__()
        self.nodes  = nodes
        self.master = master

    def ipsfromdns(self):
        IPs = socket.gethostbyname_ex(self.dns)
        if not IPs:
            raise pg_cluster_logger_exception('no IPs found by DNS {0}.'.format(self.dns))
        return sorted(IPs[2])

    def update_node_info(self):
        for node in self.nodes:
            node.update_lag()

    def __str__(self):

        state     = {}
        master_is_valid = False
        try:
            master_is_valid = self.master.master()
            if not master_is_valid:
                raise Exception('Master is no master')
        except:
            self.update_nodelist()
        try:
            if not master_is_valid:
                master_is_valid = self.master.master()
            state['master'] = self.master.ip
        except:
            state['master'] = 'unknown'

        try:
            localnode        = self.nodes[self.local_node_ip]
            state['max_con'] = localnode.config_parameter('max_connections')
            state['con']     = localnode.num_connections()
        except pg_cluster_logger_exception as e:
            if self.debug:
                print_exception(e)
            localnode         = None
            state['max_con'] = -1
            state['con']     = -1

        try:
            lag              = localnode.lag_info(self.master)
        except Exception as e:
            lag = None
            if self.debug:
                print_exception(e)
        if lag:
            state['lag_sec']     = lag[0]
            state['lag_replay']  = lag[1]
            state['lag_receive'] = lag[2]

        nodes_level = [ 0, 0, 0, 0 ]
        for k in self.nodes:
            n = self.nodes[k]
            l = n.accesslevel()
            nodes_level[n.accesslevel()] += 1
        state['nodes_down'] = nodes_level[0]
        state['nodes_ssh']  = nodes_level[1]
        state['nodes_psql'] = nodes_level[2]
        state['nodes_up']   = nodes_level[3]

        ret = " ".join(["{0}={1}".format(k, state[k]) for k in sorted(state.keys()) ])
        return ret

    def log_to_file(self, msg=None):
        if not msg:
            msg=str(self)
        if not self.logfile_obj:
            self.logfile_obj = open(self.logfile, 'a')

        line  = "{0}: {1}".format(datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S'), msg)
        if self.debug:
            print(line)

        self.logfile_obj.write(line+'\n')
        self.logfile_obj.flush()

def get_default(settngs, key, default):
    try:
        return settings[key]
    except:
        return default

def process_config_files(list_of_config_files, debug=False):
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
        except IOError as e:
            if debug:
                print_exception(e)
            pass
    return settings

if __name__ == "__main__":
    import sys
    import time
    import signal
 
    def signal_term_handler(signal, frame):
        print 'got SIGTERM'
        sys.exit(0)
 
    signal.signal(signal.SIGTERM, signal_term_handler)


    settings = process_config_files([ '/etc/repmgr.conf', '/etc/facter/facts.d/pure_cloud_cluster.ini', '/etc/pgpure/postgres/9.6/data/cluster_logger.ini' ])

    default_postgresport = get_default(settings, 'postgresport', 5432)
    default_interval     = get_default(settings, 'cluster_logger_interval', 1)
    default_dns          = get_default(settings, 'dnsname', get_default(settings, 'cluster', None))
    default_nodename     = get_default(settings, 'node_name', socket.gethostname())
    default_logfile      = get_default(settings, 'cluster_logger_logfile', '/var/log/pgpure/cluster_logger/cluster_logger.log')
    default_conn_timeout = get_default(settings, 'pgsql_connection_timeout', 3)

    import argparse
    parser = argparse.ArgumentParser(description='Check cluster status and log.')
    parser.add_argument('-d', '--dns', default=default_dns, help='DNS name to read (Without domain, domain name from machine is used).')
    parser.add_argument('-n', '--node_name', default=default_nodename, help='hostname of this node (for local monitoring)')
    parser.add_argument('-p', '--port', default=default_postgresport, help='Port where postgres is running on.')
    parser.add_argument('-i', '--interval', default=default_interval, help='Interval for checking. cluster_logger will only output changes, ir on kill -USR1')
    parser.add_argument('-l', '--logfile', default=default_logfile, help='Logfile for writing log to.')
    parser.add_argument('-t', '--conntimeout', default=default_conn_timeout, help='Timeout for postgres connections.')
    parser.add_argument('-x', '--debug', action='store_true', help='Enable debugging.')

    args = parser.parse_args()

    if not args.dns:
        print('You should set the DNS of this cluster\n- with --dns, or\n- in inifile /etc/facter/facts.d/pure_cloud_cluster.ini or\n- in config file /etc/repmgr.conf')
        sys.exit()

    if not '.' in args.dns:
        try:
            domain_name = socket.getfqdn().split('.',1)[1]
            dns = "{0}.{1}".format(args.dns, domain_name)
        except:
            dns = args.dns
    else:
        dns = args.dns

    cluster = pg_cluster(dns, postgresport=args.port, local_node_name=socket.gethostname(), logfile=args.logfile, debug=args.debug, conn_timeout=args.conntimeout)
    signal.signal(signal.SIGUSR1, lambda x, y: cluster.log_to_file())
    last_state = None
    
    while True:
        try:
            state = str(cluster)
            if state != last_state:
                cluster.log_to_file(state)
            last_state = state
        except KeyboardInterrupt:
            sys.exit(0)
        except pg_cluster_logger_exception as e:
            print_exception(e)

        try:
            time.sleep(args.interval)
        except KeyboardInterrupt:
            sys.exit(0)
