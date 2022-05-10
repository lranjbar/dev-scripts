#!/usr/bin/env bash
set -euxo pipefail

AGENT_SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
DEVSCRIPTS_SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}/.." )" && pwd )"

LOGDIR=${DEVSCRIPTS_SCRIPT_DIR}/logs
source $DEVSCRIPTS_SCRIPT_DIR/logging.sh
source $DEVSCRIPTS_SCRIPT_DIR/common.sh
source $DEVSCRIPTS_SCRIPT_DIR/network.sh
source $DEVSCRIPTS_SCRIPT_DIR/utils.sh
source $DEVSCRIPTS_SCRIPT_DIR/validation.sh
source $DEVSCRIPTS_SCRIPT_DIR/agent/common.sh

early_deploy_validation

# This allows us to test this makefile target in isolation
if [ ! -f $WORKING_DIR/ironic_nodes.json ]
  sudo cp $AGENT_SCRIPT_DIR/tests/unit/plugins/modules/data/ironic_nodes.json $WORKING_DIR/ironic_nodes.json
fi

if [ -z ${OPENSHIFT_CI+x} ]; then
  ansible-playbook $AGENT_SCRIPT_DIR/playbooks/generate_manifests.yml
else
  ansible-playbook $AGENT_SCRIPT_DIR/playbooks/generate_manifests.yml \
  -e "ci_token=${CI_TOKEN}" \
  -e "working_dir=${WORKING_DIR}" \
  -e "openshift_release_stream=${OPENSHIFT_RELEASE_STREAM}" \
  -e "openshift_release_type=${OPENSHIFT_RELEASE_TYPE}" \
  -e "openshift_version=${OPENSHIFT_VERSION}" \
  -e "cluster_name=${CLUSTER_NAME}" \
  -e "base_domain=${BASE_DOMAIN}" \
  -e "cluster_topology=${CLUSTER_TOPOLOGY}" \
  -e "resource_profile=${RESOURCE_PROFILE}" \
  -e "extra_workers_profile=${EXTRA_WORKERS_PROFILE}" \
  -e "ip_stack=${IP_STACK}" \
  -e "host_ip_stack=${HOST_IP_STACK}" \
  -e "provisioning_network_profile=${PROVISIONING_NETOWORK_PROFILE}" \
  -e "agent_static_ip_node0_only=${AGENT_STATIC_IP_NODE0_ONLY}"
fi