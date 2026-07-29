# Pobieramy informacje o "Availability Domains" (fizycznych centrach danych w regionie)
data "oci_identity_availability_domains" "ads" {
  compartment_id = var.compartment_id
}

# Szukamy najnowszego obrazu Ubuntu 24.04 ARM
data "oci_core_images" "ubuntu_arm" {
  compartment_id           = var.compartment_id
  operating_system         = "Canonical Ubuntu"
  operating_system_version = "24.04"
  shape                    = "VM.Standard.A1.Flex"
  sort_by                  = "TIMECREATED"
  sort_order               = "DESC"
}

# Tworzymy serwer (Instancję Compute)
resource "oci_core_instance" "home_cloud_server" {
  # Wybieramy pierwsze dostępne centrum danych
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
  compartment_id      = var.compartment_id
  display_name        = "home-cloud-server"
  shape               = "VM.Standard.A1.Flex"

  # NOWE LIMITY ALWAYS FREE (Czerwiec 2026)
  shape_config {
    ocpus         = 2
    memory_in_gbs = 12
  }

  create_vnic_details {
    subnet_id        = oci_core_subnet.main_subnet.id
    display_name     = "primary-vnic"
    assign_public_ip = true
  }

  source_details {
    source_type = "image"
    source_id   = data.oci_core_images.ubuntu_arm.images[0].id
    # Domyślny dysk to ok. 47 GB. Możesz rozszerzyć do 200 GB limitu Always Free, 
    # ustawiając boot_volume_size_in_gbs = 50 (lub więcej). Zostawiamy domyślnie.
  }

  metadata = {
    ssh_authorized_keys = file(var.ssh_public_key_path)
  }
}
