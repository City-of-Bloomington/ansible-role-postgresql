City-of-Bloomington.postgresql
=========

Ansible role for configuring Postgres on Ubuntu servers

Requirements
------------

City-of-Bloomington.linux


Example Playbook
----------------

```yml
- hosts: linux-postgresql
  become: yes
  roles:
  - City-of-Bloomington.postgresql
```

Copying and License
-------
This material is copyright 2016-2017 City of Bloomington, Indiana
It is open and licensed under the GNU General Public License (GLP) v3.0 whose full text may be found at:
https://www.gnu.org/licenses/gpl.txt
