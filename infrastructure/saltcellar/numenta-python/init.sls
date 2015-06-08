# ----------------------------------------------------------------------
# Numenta Platform for Intelligent Computing (NuPIC)
# Copyright (C) 2015, Numenta, Inc.  Unless you have purchased from
# Numenta, Inc. a separate commercial license for this software code, the
# following terms and conditions apply:
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License version 3 as
# published by the Free Software Foundation.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
# See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
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

anaconda-python:
  pkg:
    - installed
    - pkgs:
      - gs-anaconda
    - watch_in:
      - cmd: enforce-anaconda-permissions

anaconda-site-packages:
  file.directory:
    - name: /opt/numenta/anaconda/lib/python2.7/site-packages
    - user: ec2-user
    - group: ec2-user
    - mode: 755
    - require:
      - user: ec2-user

# Install our standard pip packages into anaconda python

anaconda-paver:
  pip.installed:
    - name: paver == 1.2.3
    - bin_env: /opt/numenta/anaconda/bin/pip
    - watch_in:
      - cmd: enforce-anaconda-permissions
    - require:
      - pkg: anaconda-python

anaconda-pip:
  pip.installed:
    - name: pip == 6.0.8
    - bin_env: /opt/numenta/anaconda/bin/pip
    - watch_in:
      - cmd: enforce-anaconda-permissions
    - require:
      - pkg: anaconda-python

# Install this from an S3 wheel so we don't need devtools on everything
anaconda-psutil:
  cmd.run:
    - name: /opt/numenta/anaconda/bin/pip install https://s3-us-west-2.amazonaws.com/yum.groksolutions.com/eggs/psutil-3.0.0-cp27-none-linux_x86_64.whl
    - creates: /opt/numenta/anaconda/lib/python2.7/site-packages/psutil-3.0.0.dist-info/WHEEL
    - watch_in:
      - cmd: enforce-anaconda-permissions
    - require:
      - pkg: anaconda-python

anaconda-setuptools:
  pip.installed:
    - name: setuptools == 4.0.1
    - bin_env: /opt/numenta/anaconda/bin/pip
    - watch_in:
      - cmd: enforce-anaconda-permissions
    - require:
      - pkg: anaconda-python

anaconda-supervisor:
  pip.installed:
    - name: supervisor == 3.1.3
    - bin_env: /opt/numenta/anaconda/bin/pip
    - watch_in:
      - cmd: enforce-anaconda-permissions
    - require:
      - pkg: anaconda-python

anaconda-wheel:
  pip.installed:
    - name: wheel == 0.24.0
    - bin_env: /opt/numenta/anaconda/bin/pip
    - watch_in:
      - cmd: enforce-anaconda-permissions
    - require:
      - pkg: anaconda-python

anaconda-yaml:
  pip.installed:
    - name: pyyaml == 3.11
    - bin_env: /opt/numenta/anaconda/bin/pip
    - watch_in:
      - cmd: enforce-anaconda-permissions
    - require:
      - pip: anaconda-pip
      - pkg: anaconda-python

# Install a python2.7 symlink so /usr/bin/env python2.7 will work
python-27-symlink:
  file.symlink:
    - target: /opt/numenta/anaconda/bin/python
    - name: /usr/local/bin/python2.7
    - require:
      - cmd: enforce-anaconda-permissions
      - pkg: anaconda-python

# Once we have installed our packages, make sure that the anaconda python
# directory tree has the correct ownership.
enforce-anaconda-permissions:
  cmd.wait:
    - name: chown -R ec2-user:ec2-user /opt/numenta/anaconda
    - require:
      - file: anaconda-site-packages
      - group: ec2-user
      - pkg: anaconda-python
      - user: ec2-user
