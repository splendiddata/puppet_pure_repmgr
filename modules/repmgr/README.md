# puppet-repmgr

## Overview

Module to install and configure repmgr from repo packages. Repmgr is a tool 
to aid management of postgresql replication and failover.

This module does not handle failback or automatic recovery of failed nodes.

The module can be used in environments where the puppet agent is constantly
running (this is a change from earlier versions).

## Module Description

This module installs and configures repmgr from repo packages. It creates 
a read/write primary and any number of read-only secondaries.

This module sets up the nodes to operate in a specific way.  Following a
failure of the primary, the highest priority secondary will promote itself
to become the new primary, and the lower priority secondary will repoint
itself to replicate from the new primary. Should the new primary also fail, the
lower priority secondary will promote itself in turn. Should this node also fail,
there would be  no working servers until puppet is run to reset the cluster.

During a failover the promoted node will attempt to shut down the failed primary in
order to avoid split-brain.

To avoid the risk of downtime following a failover, change the value of $primary
to the new primary node, drop the repmgr database on the failed primary, and run puppet on
it (or wait for the next puppet agent run if you are running the agent constantly). 
Puppet will then clone the new primary and register the node as a secondary. There
is no need to do anything to the other nodes in the cluster, and there will be no
loss of service.

This method provides the opportunity to examine a failed primary node, and the
ability to reintroduce it as a secondary with only a couple of commands.

Secondaries can be re-cloned from the primary by just stopping the postgresql
service and running the puppet agent.

### Beginning with Repmgr

This module assumes the following:
* postgresql is already installed;
* password-less SSH access between nodes is already working;
* fencing/stonith commands in perform-failover.sh are operational;
* repmgr functions are enabled in postgresql.conf;
* $repmgr_conf_dir and $repmgr_log_dir directories should already exist and have appropriate permissions.

### Usage

When initially setting up the nodes, Run puppet on the primary first, then the
secondaries.

Make the following class declaration to use defaults:

```puppet
class { 'repmgr': }
```

To override the default installed postgresql version:

```puppet
  class { 'repmgr':
    postgresql_version => '9.4',
    repmgr_conf_dir    => '/etc/postgresql/9.4/main',
    packages           => [ 'postgresql-9.4-repmgr', 'postgresql-server-dev-9.4' ],
  }
```

To set cluster-wide values:
```puppet
  class { 'repmgr':
    cluster_name => 'warehouse',
    primary      => 'wh1.example.com',
  }
```

To set node-specific values:
```puppet
  class { 'repmgr':
    node_number   => '2',
    node_name     => 'wh2',
    node_priority => '150',
  }
```

To change default repmgr database values:
```puppet
  class { 'repmgr':
    repmgr_db_name      => 'wh_repl',
    repmgr_db_user_name => 'wh_repl_usr',
  }
```

All configurable settings are visible in params.pp.

### Supported Operating Systems

Currently this module only supports Ubuntu 14.04. The intention is to add
support for other versions of Ubuntu, Debian, and RHEL, in that order.

### Limitations

This module is very young and in active development.

TODO: Requires automated tests.

TODO: set up event_notifications.
