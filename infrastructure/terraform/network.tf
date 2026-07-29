# 1. Główna sieć VCN
resource "oci_core_vcn" "main_vcn" {
  compartment_id = var.compartment_id
  cidr_blocks    = ["10.0.0.0/16"]
  display_name   = "home-cloud-vcn"
  dns_label      = "homecloud"
}

# 2. Brama internetowa
resource "oci_core_internet_gateway" "main_igw" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.main_vcn.id
  display_name   = "home-cloud-igw"
  enabled        = true
}

# 3. Tabela routingu (kieruje ruch do internetu)
resource "oci_core_route_table" "main_route_table" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.main_vcn.id
  display_name   = "home-cloud-rt"

  route_rules {
    network_entity_id = oci_core_internet_gateway.main_igw.id
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
  }
}

# 4. Firewall (Security List)
resource "oci_core_security_list" "main_security_list" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.main_vcn.id
  display_name   = "home-cloud-sl"

  # Egress - pozwalamy maszynie pobierać dane z internetu (np. aktualizacje)
  egress_security_rules {
    destination = "0.0.0.0/0"
    protocol    = "all"
  }



  # Ingress HTTP (80) - dla Caddy / strony ślubnej
  ingress_security_rules {
    protocol = "6" # TCP w OCI to "6"
    source   = "0.0.0.0/0"
    tcp_options {
      max = 80
      min = 80
    }
  }

  # Ingress HTTPS (443) - dla Caddy / strony ślubnej
  ingress_security_rules {
    protocol = "6"
    source   = "0.0.0.0/0"
    tcp_options {
      max = 443
      min = 443
    }
  }

  # Ingress Tailscale (41641) - usprawnia połączenia bezpośrednie P2P
  ingress_security_rules {
    protocol = "17" # UDP w OCI to "17"
    source   = "0.0.0.0/0"
    udp_options {
      max = 41641
      min = 41641
    }
  }

  # Wymagane przez OCI (ICMP Type 3 Code 4) do fragmentacji pakietów (Path MTU Discovery)
  ingress_security_rules {
    protocol = "1" # ICMP
    source   = "0.0.0.0/0"
    icmp_options {
      type = 3
      code = 4
    }
  }

  # UWAGA: Brak reguły dla portu 22 (SSH)! Zgodnie z planem zamykamy go na świat.
}

# 5. Podsieć dla instancji
resource "oci_core_subnet" "main_subnet" {
  compartment_id    = var.compartment_id
  vcn_id            = oci_core_vcn.main_vcn.id
  cidr_block        = "10.0.0.0/24"
  display_name      = "home-cloud-subnet"
  route_table_id    = oci_core_route_table.main_route_table.id
  security_list_ids = [oci_core_security_list.main_security_list.id]
  dns_label         = "subnet"
}
