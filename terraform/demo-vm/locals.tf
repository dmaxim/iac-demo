#--- terraform/demo-vm/locals.tf ---#

locals {
  tags = {
    environment = var.environment
  }
  vm_script = <<CUSTOM_DATA
  #!/usr/bin/env bash
  crontab -l > initcron
  echo "0 0 * * * wget https://en.wikipedia.org/wiki/Philadelphia_chromosome -O /var/tmp/wiki-download.htm" >> initcron
  crontab initcron
  CUSTOM_DATA
}