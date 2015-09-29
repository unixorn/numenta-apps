# ----------------------------------------------------------------------
# Numenta Platform for Intelligent Computing (NuPIC)
# Copyright (C) 2015, Numenta, Inc.  Unless you have purchased from
# Numenta, Inc. a separate commercial license for this software code, the
# following terms and conditions apply:
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero Public License version 3 as
# published by the Free Software Foundation.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
# See the GNU Affero Public License for more details.
#
# You should have received a copy of the GNU Affero Public License
# along with this program.  If not, see http://www.gnu.org/licenses.
#
# http://numenta.org/licenses/
# ----------------------------------------------------------------------
# Formula: numenta-python

# Install anaconda python and ensure that the packages we require are
# installed and are the correct version.
#
# Numenta style requires we lock to specific versions so we don't get
# burned again by mystery bugs when new module versions come out.

include:
  - devtools
  - nta-nucleus

# We use Anaconda on CentOS 6 because system python there is so stale it
# is still 2.6.
#
# We're running 10.10 on OS X, and its system python is 2.7.10, so we don't
# add the aggravation of another python install.

{% if grains['os_family'] == 'RedHat' %}
anaconda-python:
  pkg:
    - installed
    - pkgs:
      - gs-anaconda
    - require:
      - pkg: compiler-toolchain
    - watch_in:
      - cmd: enforce-anaconda-permissions
{% endif %}

# Install our standard pip packages into anaconda python on CentOS and system
# python on OS X.

anaconda-paver:
  pip.installed:
    - name: paver == 1.2.3
{% if grains['os_family'] == 'RedHat' %}
    - bin_env: /opt/numenta/anaconda/bin/pip
    - watch_in:
      - cmd: enforce-anaconda-permissions
    - require:
      - pkg: anaconda-python
{% endif %}

anaconda-pip:
  pip.installed:
    - name: pip == 7.1.2
{% if grains['os_family'] == 'RedHat' %}
    - bin_env: /opt/numenta/anaconda/bin/pip
    - watch_in:
      - cmd: enforce-anaconda-permissions
    - require:
      - pkg: anaconda-python
{% endif %}

anaconda-setuptools:
  pip.installed:
    - name: setuptools
    - upgrade: True
{% if grains['os_family'] == 'RedHat' %}
    - bin_env: /opt/numenta/anaconda/bin/pip
    - watch_in:
      - cmd: enforce-anaconda-permissions
    - require:
      - pkg: anaconda-python
{% endif %}

anaconda-wheel:
  pip.installed:
    - name: wheel == 0.24.0
{% if grains['os_family'] == 'RedHat' %}
    - bin_env: /opt/numenta/anaconda/bin/pip
    - watch_in:
      - cmd: enforce-anaconda-permissions
    - require:
      - pkg: anaconda-python
{%endif %}

{% if grains['os_family'] == 'RedHat' %}
# CentOS-specific fixes
# Install a python2.7 symlink so /usr/bin/env python2.7 will work on CentOS 6
python-27-symlink:
  file.symlink:
    - target: /opt/numenta/anaconda/bin/python
    - name: /usr/local/bin/python2.7
    - require:
      - cmd: enforce-anaconda-permissions
      - pkg: anaconda-python

# Once we have installed our packages, make sure that the anaconda python
# directory tree has the correct ownership on CentOS 6.
enforce-anaconda-permissions:
  cmd.wait:
    - name: chown -R ec2-user:wheel /opt/numenta/anaconda
    - require:
      - pkg: anaconda-python
      - user: ec2-user
{% endif %}
