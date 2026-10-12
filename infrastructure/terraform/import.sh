#!/usr/bin/env bash
# Import istniejacych zasobow OCI do stanu Terraform.
# Uzycie: uzupelnij 6 identyfikatorow ponizej (konsola OCI -> zasob -> OCID), potem:
#   cd infrastructure/terraform && terraform init && bash import.sh
#   terraform plan      <- przeczytaj CALY plan; do apply wolno przejsc tylko, gdy
#                          nie ma zadnego "destroy" ani "replace".
set -euo pipefail

VCN_OCID=""
IGW_OCID=""
ROUTE_TABLE_OCID=""
SECURITY_LIST_OCID=""
SUBNET_OCID=""
INSTANCE_OCID=""

for v in VCN_OCID IGW_OCID ROUTE_TABLE_OCID SECURITY_LIST_OCID SUBNET_OCID INSTANCE_OCID; do
  [ -n "${!v}" ] || { echo "Uzupelnij $v"; exit 1; }
done

terraform import oci_core_vcn.main_vcn                       "$VCN_OCID"
terraform import oci_core_internet_gateway.main_igw          "$IGW_OCID"
terraform import oci_core_route_table.main_route_table       "$ROUTE_TABLE_OCID"
terraform import oci_core_security_list.main_security_list   "$SECURITY_LIST_OCID"
terraform import oci_core_subnet.main_subnet                 "$SUBNET_OCID"
terraform import oci_core_instance.home_cloud_server         "$INSTANCE_OCID"
