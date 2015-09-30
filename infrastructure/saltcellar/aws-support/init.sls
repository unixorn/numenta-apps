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
# Formula: aws-support

# Install AWS support tooling.
{% if grains['os_family'] == 'RedHat' %}

# Add AMI test to confirm that getsshkeys is installed
/etc/numenta/tests/test_getsshkeys.py:
  file.managed:
    - source: salt://aws-support/files/tests/test_getsshkeys.py
    - mode: 0755
    - require:
      - file: ami-test-directory

# Add a shell snippet you can include to read an instance's IAM credentials
/etc/numenta/read-iam-role-credentials.sh:
  file.managed:
    - source: salt://aws-support/files/read-iam-role-credentials.sh
    - mode: 0644
    - require:
      - file: /etc/numenta

# Add service to read ssh keys from EC2 environment
/etc/init.d/getsshkeys:
  file.managed:
    - source: salt://aws-support/files/getsshkeys.initd
    - mode: 0755

# Add AWS info to /etc/motd
/etc/update-motd.d/20-aws-info.motd:
  file.managed:
    - source: salt://aws-support/files/20-aws-info.motd
    - user: root
    - group: wheel
    - mode: 0755
    - require:
      - file: /etc/update-motd.d
    - watch_in:
      - cmd: update-motd


# Load SSH keys from EC2 on boot
getsshkeys:
  service.enabled

# Install aws tool packages
aws-tools:
  pkg:
    - latest
    - pkgs:
      - ec2-metadata
      - s3cmd
{% endif %}

{% if grains['os_family'] == 'MacOS' %}
# Mac versions of the AWS packages. Salt brew module doesn't support
# pkg.latest :-()
# We also don't need ec2-metadata since OS X won't run in EC2.
aws-tools:
  pkg:
    - installed
    - pkgs:
      - s3cmd
{% endif %}
