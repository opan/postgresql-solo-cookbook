postgresql_wrapper Cookbook
===========================

This cookbook is a wrapper cookbook around public cookbook postgresql

We have 2 recipes in this cookbook

1. server.rb :- This recipe is used to setup a postgresql server.

2. client.rb :- This recipe is used to install all the client packages
   which are required to connect to a postgresql server

## Local Dev Setup

* To test postgres master

```
kitchen conver default-master-ubuntu-1604

```

* To test postgres slave

```
kitchen conver default-slave-ubuntu-1604

```

